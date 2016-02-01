From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net] net: Allow flow dissector to handle non 4-byte
 aligned headers
Date: Mon, 1 Feb 2016 16:20:35 +0100
Message-ID: <56AF77C3.2010406@6wind.com>
References: <1454276221-3543907-1-git-send-email-tom@herbertland.com>
 <1454286240.7627.160.camel@edumazet-glaptop2.roam.corp.google.com>
 <56AEA947.409@gmail.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	sowmini.varadhan@oracle.com, kernel-team@fb.com
To: Florian Fainelli <f.fainelli@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:38778 "EHLO
	mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754001AbcBAPUi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Feb 2016 10:20:38 -0500
Received: by mail-wm0-f47.google.com with SMTP id p63so76250863wmp.1
        for <netdev@vger.kernel.org>; Mon, 01 Feb 2016 07:20:37 -0800 (PST)
In-Reply-To: <56AEA947.409@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 01/02/2016 01:39, Florian Fainelli a =C3=A9crit :
> Le 31/01/2016 16:24, Eric Dumazet a =C3=A9crit :
>> On Sun, 2016-01-31 at 13:37 -0800, Tom Herbert wrote:
>>> Call get_unaligned_be32 when we access 32-bit fields in
>>> __skb_flow_dissect. At the beginning check for unlikely case of
>>> 1-byte aligned packet.
>>>
>>> Note that flow_dissector may be asked to parse packet unaligned
>>> fields in two instances:
>>>
>>> 1) Packet from a driver which is aligned to Ethernet header
>>>     (2-byte alignment)
>>> 2) Parsing inner headers of a received GRE-TEB packet
>>>
>>> Testing: Ran super_netperf tests did not see a regression. This was=
 on
>>> x86 which does not have problems with unaligned data.
>>
>> But this test is absolutely useless, what about testing arches that
>> actually care ?
>>
>> I am told all these MIPS based boxes have already not enough cpu pow=
er.
>
> How about the Cavium OCTEON family and Broadcom/Netlogic XLR/XLP, tho=
se
> are massively multi-core and MIPS64 capable, even though they may not
> always run a Linux networking stack, some do.
>
> There are also plenty of ARMv7/ARMv8 devices out there that would
> benefit from proper alignment some might end-up using mlx4/5 and inte=
l
> cards.
There is also the tile architecture, up to 76 cores on the board I've s=
een. It
requires an alignment on 8!
I wonder how this case may be properly handled. A simple ipip scenario =
fails.
