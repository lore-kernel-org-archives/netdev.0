From: Thomas Graf <tgraf@infradead.org>
Subject: Re: increase the number of routing tables
Date: Mon, 30 Jan 2012 07:25:46 -0500
Message-ID: <20120130122546.GE8376@canuck.infradead.org>
References: <CANj2EbfR0cBaBd+t1yCZyErRpVzSC00DZohvtyazK8_9bv2aEQ@mail.gmail.com>
 <1327804887.2805.20.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Simon Chen <simonchennj@gmail.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:40892 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751181Ab2A3MZr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2012 07:25:47 -0500
Content-Disposition: inline
In-Reply-To: <1327804887.2805.20.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 29, 2012 at 03:41:27AM +0100, Eric Dumazet wrote:
> Le samedi 28 janvier 2012 =E0 21:20 -0500, Simon Chen a =E9crit :
> > Hey folks,
> >=20
> > To my limited knowledge, Linux currently supports 256 (255?) routin=
g
> > tables defined in /etc/iproute2/rt_tables.
> >=20
> > Is there a way to increase this number to something much larger? Ar=
e
> > there performance/scalability concerns there? I am trying to have
> > customized routing table for each IP address (using "ip rule add fr=
om
> > xxx table yyy"). I am not sure exactly how many IPs I'll handle, bu=
t
> > certainly more than 255...
> >=20
>=20
> Its is possible, but probably not scalable.
>=20
> You really should not have too many "ip rule" entries, since they are
> evaluated linearly.
>=20
> The limit being ~32768 rules
>=20
> # ip rule
> 0:	from all lookup local=20
> 32763:	from all to 1.2.3.7 lookup test3000=20
> 32766:	from all lookup main=20
> 32767:	from all lookup default=20

I've run into these scalability issues a while ago which is
why I've added the goto action allowing to build a tree like
structures:

0:	from all lookup local=20
10:     from eth0 goto 4000
[possibly thousands of rules]
3999:   from all goto 32763
4000:   from all to 1.1.1.1 lookup foo
[...]
32763:	from all to 1.2.3.7 lookup test3000=20
32766:	from all lookup main=20
32767:	from all lookup default=20
