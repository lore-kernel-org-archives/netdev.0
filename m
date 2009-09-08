From: thomas yang <lampsu@gmail.com>
Subject: Re: [iproute2] tc action mirred question
Date: Tue, 8 Sep 2009 21:50:29 +0800
Message-ID: <f4f837ab0909080650t343efbmeb2f121def40bd9f@mail.gmail.com>
References: <404956.88336.qm@web111607.mail.gq1.yahoo.com>
	 <1252376168.5244.11.camel@dogo.mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f175.google.com ([209.85.223.175]:36860 "EHLO
	mail-iw0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754285AbZIHNu1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Sep 2009 09:50:27 -0400
Received: by iwn5 with SMTP id 5so1140028iwn.4
        for <netdev@vger.kernel.org>; Tue, 08 Sep 2009 06:50:30 -0700 (PDT)
In-Reply-To: <1252376168.5244.11.camel@dogo.mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2009/9/8 jamal <hadi@cyberus.ca>:
> On Mon, 2009-09-07 at 09:05 -0700, Xiaofei Wu wrote:
>
>> (1) Could I use =A0pedit action to modify the dst MAC, so the destin=
ation node D will accept it,
>> then forward it to node C?
>
> Yes, you can achieve it with pedit;
>
>
>> (or use other tools to modify the dst MAC, please give me more infor=
mation)
>>
>
> it is as usable as u32 is - you have to know your offsets
> example, here's something done on an incoming packet:
> =3D-=3D
> #Note:
> #dst MAC starts at -14
> #src MAC at -8
> #ethertype at -2
> #
> tc filter add dev eth1 parent ffff: protocol ip prio 10 u32 \
> match ip src 192.168.2.11/32 flowid 1:2 \
> action pedit munge offset -14 u16 set 0x0000 \
> munge offset -12 u32 set 0x00000200 \
> munge offset -8 u32 set 0x0aaf0100 \
> munge offset -4 u32 set 0x0008eb06 pipe \
> action mirred egress redirect dev eth0


He want to route the mirroring packets.

" - Mirror takes a copy of the packet and sends it to specified
 dev ("port" in ethernet switch/bridging terminology)
 - redirect
 steals the packet and redirects to specified destination dev. "

So,'mirror' is different from 'redirect'.  Change the line 'action
mirred egress redirect dev eth0' to 'action mirred egress mirror dev
eth0' .
Both 'mirror' and 'redirect'  can transmit the packets to otner node,
but mirror make a copy, then transmit it;  redirect steals the packet,
right  ?


--
regards,
thomas
