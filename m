From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH net-next-2.6] bridge: add __rcu annotations
Date: Tue, 16 Nov 2010 21:59:22 +0900
Message-ID: <20101116125922.GA9538@verge.net.au>
References: <1289636128.2743.15.camel@edumazet-laptop>
 <20101113093545.6fe9c077@nehalam>
 <1289671130.2743.28.camel@edumazet-laptop>
 <20101113101320.4b1c9ba7@nehalam>
 <1289685861.2743.38.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:55074 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756293Ab0KPM7Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Nov 2010 07:59:25 -0500
Content-Disposition: inline
In-Reply-To: <1289685861.2743.38.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 13, 2010 at 11:04:21PM +0100, Eric Dumazet wrote:
> Le samedi 13 novembre 2010 =C3=A0 10:13 -0800, Stephen Hemminger a =C3=
=A9crit :
> > On Sat, 13 Nov 2010 18:58:50 +0100
> > Eric Dumazet <eric.dumazet@gmail.com> wrote:
> >=20
> > > Le samedi 13 novembre 2010 =C3=A0 09:35 -0800, Stephen Hemminger =
a =C3=A9crit :
> > > > On Sat, 13 Nov 2010 09:15:28 +0100
> > > > Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > > >=20
> > > > > diff --git a/include/linux/netdevice.h b/include/linux/netdev=
ice.h
> > > > > index 578debb..ffbd177 100644
> > > > > --- a/include/linux/netdevice.h
> > > > > +++ b/include/linux/netdevice.h
> > > > > @@ -996,7 +996,10 @@ struct net_device {
> > > > >  #endif
> > > > > =20
> > > > >  	rx_handler_func_t	*rx_handler;
> > > > > -	void			*rx_handler_data;
> > > > > +	union {
> > > > > +		void				*rx_handler_data;
> > > > > +		struct net_bridge_port __rcu	*br_port_rcu;
> > > > > +	};
> > > > > =20
> > > > >  	struct netdev_queue __rcu *ingress_queue;
> > > >=20
> > > > I don't like making the generic hook typed again.
> > > > We don't do this for other callbacks, timers, workqueues, ...
> > > > Why is it necessary for RCU notation.
> > > >=20
> > >=20
> > > because rcu_dereference() needs the type for __CHECKER__/sparse c=
hecks
> > >=20
> > > #define __rcu_dereference_check(p, c, space) \
> > >         ({ \
> > >                 typeof(*p) *_________p1 =3D (typeof(*p)*__force )=
ACCESS_ONCE(p); \
> > >                 rcu_lockdep_assert(c); \
> > >                 rcu_dereference_sparse(p, space); \
> > >                 smp_read_barrier_depends(); \
> > >                 ((typeof(*p) __force __kernel *)(_________p1)); \
> > >         })
> > >=20
> > > So using a "void *ptr" is not an option
> > >=20
> > > Its also cleaner to use
> > >=20
> > > rcu_dereference(dev->br_port_rcu)
> > >=20
> > > instead of=20
> > >=20
> > > (struct net_bridge_port *)rcu_dereference(dev->rx_handler_data)
> >=20
> > There must be a better way. What about use of that hook by macvlan =
and openvswitch?
>=20
> macvlan and openvswitch (is it part of linux yet ???)

No, openvswitch's datapath hasn't been submitted to netdev yet.

[snip]
