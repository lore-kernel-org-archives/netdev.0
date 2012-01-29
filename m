From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: increase the number of routing tables
Date: Sun, 29 Jan 2012 03:41:27 +0100
Message-ID: <1327804887.2805.20.camel@edumazet-laptop>
References: <CANj2EbfR0cBaBd+t1yCZyErRpVzSC00DZohvtyazK8_9bv2aEQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Simon Chen <simonchennj@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:39334 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751430Ab2A2Clb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Jan 2012 21:41:31 -0500
Received: by wics10 with SMTP id s10so2499913wic.19
        for <netdev@vger.kernel.org>; Sat, 28 Jan 2012 18:41:29 -0800 (PST)
In-Reply-To: <CANj2EbfR0cBaBd+t1yCZyErRpVzSC00DZohvtyazK8_9bv2aEQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 28 janvier 2012 =C3=A0 21:20 -0500, Simon Chen a =C3=A9crit :
> Hey folks,
>=20
> To my limited knowledge, Linux currently supports 256 (255?) routing
> tables defined in /etc/iproute2/rt_tables.
>=20
> Is there a way to increase this number to something much larger? Are
> there performance/scalability concerns there? I am trying to have
> customized routing table for each IP address (using "ip rule add from
> xxx table yyy"). I am not sure exactly how many IPs I'll handle, but
> certainly more than 255...
>=20

Its is possible, but probably not scalable.

You really should not have too many "ip rule" entries, since they are
evaluated linearly.

The limit being ~32768 rules

# ip rule
0:	from all lookup local=20
32763:	from all to 1.2.3.7 lookup test3000=20
32766:	from all lookup main=20
32767:	from all lookup default=20

# cat /etc/iproute2/rt_tables
#
# reserved values
#
255	local
254	main
253	default
0	unspec
#
# local
#
#1	inr.ruhep

3000 test3000

# ip route list table 3000
1.2.3.4 dev eth0  scope link=20
