From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2 rfc 0/8] IGMP snooping for local traffic
Date: Wed, 06 Sep 2017 09:06:23 -0700
Message-ID: <9ECEF4E4-A39B-4578-8BDC-7842D20F3C81@gmail.com>
References: <1504654510-31004-1-git-send-email-andrew@lunn.ch> <20170906004703.GB27385@lunn.ch> <CAJieiUj-ObfKAZa18JxnWSswLGK-mRLjqE7qyCrZ5tsVftf46w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: netdev <netdev@vger.kernel.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Woojung.Huh@microchip.com, jbe@pengutronix.de,
        sean.wang@mediatek.com, john@phrozen.org
To: Roopa Prabhu <roopa@cumulusnetworks.com>,
        Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f43.google.com ([209.85.218.43]:32824 "EHLO
        mail-oi0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932136AbdIFQGa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 6 Sep 2017 12:06:30 -0400
Received: by mail-oi0-f43.google.com with SMTP id r20so15301889oie.0
        for <netdev@vger.kernel.org>; Wed, 06 Sep 2017 09:06:30 -0700 (PDT)
In-Reply-To: <CAJieiUj-ObfKAZa18JxnWSswLGK-mRLjqE7qyCrZ5tsVftf46w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On September 6, 2017 8:54:33 AM PDT, Roopa Prabhu <roopa@cumulusnetworks=2E=
com> wrote:
>On Tue, Sep 5, 2017 at 5:47 PM, Andrew Lunn <andrew@lunn=2Ech> wrote:
>>> The third and last issue will be explained in a followup email=2E
>>
>> Hi DSA hackers
>>
>> So there is the third issue=2E It affects just DSA, but it possible
>> affects all DSA drivers=2E
>>
>> This patchset broken broadcast with the Marvell drivers=2E It could
>> break broadcast on others drivers as well=2E
>>
>> What i found is that the Marvell chips don't flood broadcast frames
>> between bridged ports=2E What appears to happen is there is a fdb miss,
>> so it gets forwarded to the CPU port for the host to deal with=2E The
>> software bridge when floods it out all ports of the bridge=2E
>>
>> But the set offload_fwd_mark patch changes this=2E The software bridge
>> now assumes the hardware has already flooded broadcast out all ports
>> of the switch as needed=2E So it does not do any flooding itself=2E As =
a
>> result, on Marvell devices, broadcast packets don't get flooded at
>> all=2E
>>
>> The issue can be fixed=2E I just need to add an mdb entry for the
>> broadcast address to each port of the bridge in the switch, and the
>> CPU port=2E  But i don't know at what level to do this=2E
>>
>> Should this be done at the DSA level, or at the driver level?  Do any
>> chips do broadcast flooding in hardware already? Hence they currently
>> see broadcast duplication? If i add a broadcast mdb at the DSA level,
>> and the chip is already hard wired to flooding broadcast, is it going
>> to double flood?
>>
>
>On the switch asics we work with, the driver has information if the
>packet was
>forwarded in hardware=2E This is per packet reason code telling why the
>CPU is seeing the packet=2E
>The driver can use this information to reset skb->offload_fwd_mark to
>allow software forward=2E

I am not positive this is universally available across different switch ve=
ndors=2E In Broadcom tag (net/dsa/tag_brcm=2Ec) the reason code definitely =
tells you that but it also largely depends on whether you have configured S=
W managed forwarding or not and that translates in having either the HW do =
all the address learning itself or having SW do it which is less desirable =
since you end-up with a possibility huge FDB of 4k entries to manage in SW=
=2E


--=20
Florian
