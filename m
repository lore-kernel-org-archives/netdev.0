From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: mmotm 2010-04-28 - RCU whinges
Date: Mon, 3 May 2010 11:16:29 -0700
Message-ID: <20100503181629.GJ2597@linux.vnet.ibm.com>
References: <201004290021.o3T0L04Y028017@imap1.linux-foundation.org>
 <5702.1272822394@localhost>
 <1272865137.2173.179.camel@edumazet-laptop>
 <5933.1272897014@localhost>
 <1272898726.2226.47.camel@edumazet-laptop>
 <5112.1272900590@localhost>
 <20100503154357.GF2597@linux.vnet.ibm.com>
 <1272903293.2226.50.camel@edumazet-laptop>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Valdis.Kletnieks@vt.edu, Andrew Morton <akpm@linux-foundation.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1272903293.2226.50.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, May 03, 2010 at 06:14:53PM +0200, Eric Dumazet wrote:
> Le lundi 03 mai 2010 =E0 08:43 -0700, Paul E. McKenney a =E9crit :
>=20
> > Highly recommended.  ;-)
> >=20
> > And thanks to you for your testing efforts and to Eric for the fixe=
s!!!
> >=20
>=20
> For this last one, I think you should push following patch Paul

I would be happy to if I could find the commit creating
hlist_for_each_entry_continue_rcu()...

I do see a ca. 2008 patch from Stephen Hemminger:

	http://www.mail-archive.com/linux-kernel@vger.kernel.org/msg264661.htm=
l

According to http://patchwork.ozlabs.org/patch/47997/, this is
going up the networking tree as of March 18, 2010.

So I would be happy to push the patch below, but to do so, I will need
to adopt the portion of Stephen's patch that created this primitive.

Please let me know how you would like to proceed!

							Thanx, Paul

> Followup of commit 3120438ad6
> (rcu: Disable lockdep checking in RCU list-traversal primitives)
>=20
> Or we might introduce a hlist_for_each_entry_continue_rcu_bh() macro.=
=2E.
>=20
>=20
>=20
> diff --git a/include/linux/rculist.h b/include/linux/rculist.h
> index 004908b..b0c7e24 100644
> --- a/include/linux/rculist.h
> +++ b/include/linux/rculist.h
> @@ -435,10 +435,10 @@ static inline void hlist_add_after_rcu(struct h=
list_node *prev,
>   * @member:	the name of the hlist_node within the struct.
>   */
>  #define hlist_for_each_entry_continue_rcu(tpos, pos, member)		\
> -	for (pos =3D rcu_dereference((pos)->next);			\
> +	for (pos =3D rcu_dereference_raw((pos)->next);			\
>  	     pos && ({ prefetch(pos->next); 1; }) &&			\
>  	     ({ tpos =3D hlist_entry(pos, typeof(*tpos), member); 1; });  \
> -	     pos =3D rcu_dereference(pos->next))
> +	     pos =3D rcu_dereference_raw(pos->next))
>=20
>=20
>  #endif	/* __KERNEL__ */
>=20
>=20
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
