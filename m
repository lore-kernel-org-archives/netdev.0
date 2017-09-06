From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: [PATCH v2 rfc 0/8] IGMP snooping for local traffic
Date: Wed, 6 Sep 2017 08:54:33 -0700
Message-ID: <CAJieiUj-ObfKAZa18JxnWSswLGK-mRLjqE7qyCrZ5tsVftf46w@mail.gmail.com>
References: <1504654510-31004-1-git-send-email-andrew@lunn.ch> <20170906004703.GB27385@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: netdev <netdev@vger.kernel.org>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Woojung.Huh@microchip.com, jbe@pengutronix.de,
        sean.wang@mediatek.com, john@phrozen.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f174.google.com ([209.85.217.174]:34577 "EHLO
        mail-ua0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753682AbdIFPyf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 6 Sep 2017 11:54:35 -0400
Received: by mail-ua0-f174.google.com with SMTP id s15so14513502uag.1
        for <netdev@vger.kernel.org>; Wed, 06 Sep 2017 08:54:34 -0700 (PDT)
In-Reply-To: <20170906004703.GB27385@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 5, 2017 at 5:47 PM, Andrew Lunn <andrew@lunn.ch> wrote:
>> The third and last issue will be explained in a followup email.
>
> Hi DSA hackers
>
> So there is the third issue. It affects just DSA, but it possible
> affects all DSA drivers.
>
> This patchset broken broadcast with the Marvell drivers. It could
> break broadcast on others drivers as well.
>
> What i found is that the Marvell chips don't flood broadcast frames
> between bridged ports. What appears to happen is there is a fdb miss,
> so it gets forwarded to the CPU port for the host to deal with. The
> software bridge when floods it out all ports of the bridge.
>
> But the set offload_fwd_mark patch changes this. The software bridge
> now assumes the hardware has already flooded broadcast out all ports
> of the switch as needed. So it does not do any flooding itself. As a
> result, on Marvell devices, broadcast packets don't get flooded at
> all.
>
> The issue can be fixed. I just need to add an mdb entry for the
> broadcast address to each port of the bridge in the switch, and the
> CPU port.  But i don't know at what level to do this.
>
> Should this be done at the DSA level, or at the driver level?  Do any
> chips do broadcast flooding in hardware already? Hence they currently
> see broadcast duplication? If i add a broadcast mdb at the DSA level,
> and the chip is already hard wired to flooding broadcast, is it going
> to double flood?
>

On the switch asics we work with, the driver has information if the packet was
forwarded in hardware. This is per packet reason code telling why the
CPU is seeing the packet.
The driver can use this information to reset skb->offload_fwd_mark to
allow software forward.
