From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: RCU'ed dst_get_neighbour()
Date: Wed, 30 Nov 2011 00:11:01 +0100
Message-ID: <1322608261.2596.48.camel@edumazet-laptop>
References: <alpine.WNT.2.00.1111291027320.1036@TSI>
	 <1322589661.2596.2.camel@edumazet-laptop>
	 <1322599437.2596.10.camel@edumazet-laptop>
	 <CAG4TOxNJfr3X1p358LBWdNQKdkw8KOSekcKpNu6K5_phPEiR4A@mail.gmail.com>
	 <1322599991.2596.11.camel@edumazet-laptop>
	 <alpine.WNT.2.00.1111291359290.1036@TSI>
	 <1322601444.2596.21.camel@edumazet-laptop>
	 <1322602283.2596.25.camel@edumazet-laptop>
	 <alpine.WNT.2.00.1111291527360.228@TSI>
	 <1322606542.2596.43.camel@edumazet-laptop>
	 <alpine.WNT.2.00.1111291600220.228@TSI>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Marc Aurele La France <tsi-yfeSBMgouQgsA/PxXw9srA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <alpine.WNT.2.00.1111291600220.228@TSI>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Le mardi 29 novembre 2011 =C3=A0 16:03 -0700, Marc Aurele La France a =C3=
=A9crit :

> No, only warnings (splats as you call them) would be produced.  The f=
act=20
> is you added side-effects to dst_get_neighbour(), and I would expect =
all=20
> its invocations to be affected.
>=20

A splat _is_ a bad thing.

We certainly have some bugs, but I sent an infiniband patch, not a
'change the world' one ;)

Most of the network stack is run under rcu_read_lock() already.

If you notice other lockdep splats, please shout :)

Some changes are needed now rcu_read_lock_bh() doesnt imply
rcu_read_lock().

=46or example, recently added skb_update_prio() is buggy, since it uses
rcu_dereference() while its caller, dev_queue_xmit() called
rcu_read_lock_bh()



--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
