From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: A question about MTUs and TCP stack
Date: Sun, 21 Aug 2011 22:05:05 +0200
Message-ID: <1313957105.2598.10.camel@edumazet-laptop>
References: <A55791AD2520D54CA92150D16630D03B36116A5B@VA3DIAXVS1F1.RED001.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Pawan Singh <psingh@silver-peak.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:51383 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751410Ab1HUUFL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Aug 2011 16:05:11 -0400
Received: by wyg24 with SMTP id 24so3098671wyg.19
        for <netdev@vger.kernel.org>; Sun, 21 Aug 2011 13:05:09 -0700 (PDT)
In-Reply-To: <A55791AD2520D54CA92150D16630D03B36116A5B@VA3DIAXVS1F1.RED001.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 16 ao=C3=BBt 2011 =C3=A0 11:33 -0700, Pawan Singh a =C3=A9crit=
 :
> Hi
>=20
> I am posting this question to "netdev" mailing list because I could n=
o
> longer find "linux-net" mailing list.
>=20
> I find that the Linux TCP stack consumes huge amount of CPU if the MT=
U
> of an interface is set to 2400 and it is receiving 1000 byte Ethernet
> packets. On the other hand, if the MTU is set to 1500, the CPU
> consumption is reduced drastically. Increased CPU usage causes networ=
k
> throughput to drop considerably (from 800-900 Mbps to 200 Mbps). My
> kernel version is fedora core 6 and we are using 1 Gig NICs (Intel
> 82546GB and Broadcom NetXtreme BCM5721):
>=20
> Linux he7700-tg 2.6.22.14-72.fc6 #1 SMP Wed Nov 21 14:10:25 EST 2007
> x86_64 x86_64 x86_64 GNU/Linux
>=20
> I do not know the TCP buffer management internals and how they are
> affected by MTU. Is there some FAQ/information online or do I have to
> open up the source code and try to identify the source of the problem=
=2E
> I guess I can also try newer versions of the kernel and see if the
> issue has been resolved.
>=20

I suspect you have a CPU problem on the receiver side, not on transmit
one ?

MTU has a direct impact on skb 'truesize'. As the linux tcp stack takes
care of not using too much kernel ram for the sole use of one socket,
you might hit a per socket limit faster with big MTU (and not filled RX
buffers)

When this limit is hit, tcp stack tries to 'collapse' consecutive skbs
to remove the unused parts of skbs. This is a very expensive process.

With a recent kernel, you could use 'perf top' tool and easily spot the
hot paths in kernel.

