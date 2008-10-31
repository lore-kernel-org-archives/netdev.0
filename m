From: David Miller <davem@davemloft.net>
Subject: Re: [tbench regression fixes]: digging out smelly deadmen.
Date: Fri, 31 Oct 2008 00:52:19 -0700 (PDT)
Message-ID: <20081031.005219.141937694.davem@davemloft.net>
References: <20081026122300.GA30905@ioremap.net>
	<20081030111526.7d9bb0f8@extreme>
	<Pine.LNX.4.64.0810302047030.22084@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, zbr@ioremap.net, rjw@sisk.pl, mingo@elte.hu,
	s0mbre@tservice.net.ru, a.p.zijlstra@chello.nl,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	efault@gmx.de, akpm@linux-foundation.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38791
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752412AbYJaHwo convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Oct 2008 03:52:44 -0400
In-Reply-To: <Pine.LNX.4.64.0810302047030.22084@wrl-59.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Thu, 30 Oct 2008 21:01:19 +0200 (EET)

> On Thu, 30 Oct 2008, Stephen Hemminger wrote:
>=20
> > Has anyone looked into the impact of port randomization on this ben=
chmark.
> > If it is generating lots of sockets quickly there could be an impac=
t:
> >   * port randomization causes available port space to get filled no=
n-uniformly
> >     and what was once a linear scan may have to walk over existing =
ports.
> >     (This could be improved by a hint bitmap)
> >=20
> >   * port randomization adds at least one modulus operation per sock=
et
> >     creation. This could be optimized by using a loop instead.
>=20
> I did something with AIM9's tcp_test recently (1-2 days ago depending=
 on=20
> how one calculates that so didn't yet have time summarize the details=
 in=20
> the AIM9 thread) by deterministicly binding in userspace and got much=
 more=20
> sensible numbers than with randomized ports (2-4%/5-7% vs 25% variati=
on=20
> some difference in variation in different kernel versions even with=20
> deterministic binding). Also, I'm still to actually oprofile and bise=
ct=20
> the remaining ~4% regression (around 20% was reported by Christoph). =
=46or=20
> oprofiling I might have to change aim9 to do predefined number of loo=
ps=20
> instead of a deadline to get more consistent view on changes in per f=
unc=20
> runtime.

Yes, it looks like port selection cache and locking effects are
a very real issue.

Good find.
