From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: RCU'ed dst_get_neighbour()
Date: Tue, 29 Nov 2011 23:42:22 +0100
Message-ID: <1322606542.2596.43.camel@edumazet-laptop>
References: <alpine.WNT.2.00.1111291027320.1036@TSI>
	 <1322589661.2596.2.camel@edumazet-laptop>
	 <1322599437.2596.10.camel@edumazet-laptop>
	 <CAG4TOxNJfr3X1p358LBWdNQKdkw8KOSekcKpNu6K5_phPEiR4A@mail.gmail.com>
	 <1322599991.2596.11.camel@edumazet-laptop>
	 <alpine.WNT.2.00.1111291359290.1036@TSI>
	 <1322601444.2596.21.camel@edumazet-laptop>
	 <1322602283.2596.25.camel@edumazet-laptop>
	 <alpine.WNT.2.00.1111291527360.228@TSI>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Marc Aurele La France <tsi-yfeSBMgouQgsA/PxXw9srA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <alpine.WNT.2.00.1111291527360.228@TSI>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Le mardi 29 novembre 2011 =C3=A0 15:32 -0700, Marc Aurele La France a =C3=
=A9crit :
> On Tue, 29 Nov 2011, Eric Dumazet wrote:
>=20
> > Le mardi 29 novembre 2011 =C3=A0 22:17 +0100, Eric Dumazet a =C3=A9=
crit :
> >> Le mardi 29 novembre 2011 =C3=A0 14:00 -0700, Marc Aurele La Franc=
e a =C3=A9crit :
> >>> On Tue, 29 Nov 2011, Eric Dumazet wrote:
> >>>> Oh well, I forgot one rcu_read_unlock(), I'll send a V2...
>=20
> >>> This also doesn't address the other dst_get_neighbour() instances
> >>> introduced by
> >>> http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux.git;a=3D=
commitdiff;h=3D69cce1d1404968f78b177a0314f5822d5afdbbfb
>=20
> >> Oh well, a complete audit is needed, and I have no choice but doin=
g it.
>=20
> > Here is the result of this audit, please double check and test it, =
I
> > only compiled this.
>=20
> > [PATCH V2] drivers/infiniband: fix lockdep splats
>=20
> > commit f2c31e32b37 (net: fix NULL dereferences in check_peer_redir(=
))
> > forgot to take care of infiniband uses of dst neighbours.
>=20
> > Many thanks to Marc Aurele who provided a nice bug report and feedb=
ack.
>=20
> > Reported-by: Marc Aurele La France <tsi-yfeSBMgouQgsA/PxXw9srA@public.gmane.org>
> > Signed-off-by: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> > CC: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
> > CC: Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
> > ---
> > drivers/infiniband/core/addr.c                 |    9 +++++--
> > drivers/infiniband/hw/cxgb3/iwch_cm.c          |    4 +++
> > drivers/infiniband/hw/cxgb4/cm.c               |    6 +++++
> > drivers/infiniband/hw/nes/nes_cm.c             |    6 +++--
> > drivers/infiniband/ulp/ipoib/ipoib_main.c      |   18 +++++++++----=
--
> > drivers/infiniband/ulp/ipoib/ipoib_multicast.c |    6 +++--
> > 6 files changed, 35 insertions(+), 14 deletions(-)
>=20
> This looks good to me, although I'm a little iffy on your use of
> dst_get_neighbour_raw(), but that could be just me.
>=20

If you only test the neigh pointer being null (or not null), you dont
need to rcu_read_lock() before.

> But your audit is incomplete, a grep of 3.1.3 for dst_get_neighbour()=
 and=20
> dst_get_neighbour_raw() reveals occurrences in ...
>=20

:=3D)

> include/net/dst.h
> net/atm/clip.c
> net/sched/sch_teql.c
> net/core/neighbour.c
> net/ipv4/ip_gre.c
> net/ipv4/ip_output.c
> net/ipv4/route.c
> net/xfrm/xfrm_policy.c
> net/bridge/br_netfilter.c
> net/decnet/dn_neigh.c
> net/decnet/dn_route.c
> net/ipv6/sit.c
> net/ipv6/addrconf.c
> net/ipv6/route.c
> net/ipv6/ndisc.c
> net/ipv6/ip6_output.c
> net/ipv6/ip6_fib.c
>=20

So you did a grep but did not an analysis, did you ?

All these are already covered, or else bad things would already
happened.=20

Thanks


--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
