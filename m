From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: Re: kernel 2.6.25-rc7 highly unstable on high load
Date: Fri, 28 Mar 2008 13:23:59 -0700
Message-ID: <20080328132359.15573601@speedy>
References: <47EBC641.8040405@cosmosbay.com>
	<20080327183745.M9944@visp.net.lb>
	<47EBEDC9.6080100@cosmosbay.com>
	<20080327.150308.205829519.davem@davemloft.net>
	<20080328052543.M60286@visp.net.lb>
	<47EC8701.1080604@cosmosbay.com>
	<20080328073854.M73368@visp.net.lb>
	<47ECA24C.10803@cosmosbay.com>
	<47ED1583.5010204@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	Denys Fedoryshchenko <denys@visp.net.lb>,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <47ED1583.5010204@cosmosbay.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 28 Mar 2008 16:57:55 +0100
Eric Dumazet <dada1@cosmosbay.com> wrote:

> Eric Dumazet a =C3=A9crit :
> > Denys Fedoryshchenko a =C3=A9crit :
> >> Already patched and tested, it doesn't change anything.
> >>
> >>  =20
> >
> > We still leak dsts somewhere.
> >
> > You could try git bisect, or try to patch net/core/dst.c so that=20
> > dst_gc_task() (line 83) displays
> > route informations for say 10 first entries found in the dst_busy_l=
ist
> > (refcnt, interface, source IP, dest IP, things like that) that coul=
d=20
> > ring a bell given your netfilter rules or network conf.
>=20
> I cooked a patch (untested) to implement this idea :
>=20
> It should display lines similar to /proc/net/rt_cache (reusing the sa=
me=20
> helper function)
>=20
>

I wonder how much the route cache really helps when it grows so large?
Robert Olsson had suggested that turning it off when routing would help=
=2E
Perhaps the route cache is only really useful for local destinations? I=
f the
cost of maintaining the route cache exceeds the cost of just using the =
existing
route table, there is no value to having a route cache.
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
