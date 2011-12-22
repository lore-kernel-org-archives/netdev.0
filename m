From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference in
 ipv6_select_ident
Date: Thu, 22 Dec 2011 09:05:38 +0100
Message-ID: <1324541138.2621.45.camel@edumazet-laptop>
References: <1324488984.2301.45.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <1324490401.2301.46.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4EF23BF2.4000601@bootc.net> <1324499332.2621.7.camel@edumazet-laptop>
	 <1324500775.2621.9.camel@edumazet-laptop> <4EF2568C.6040006@bootc.net>
	 <AEC29013-98F3-4A16-A88B-AD31C9E88EB8@bootc.net>
	 <1324528656.2621.19.camel@edumazet-laptop>
	 <20111222063806.GP6348@secunet.com>
	 <1324540277.2621.41.camel@edumazet-laptop>
	 <20111222075830.GR6348@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Chris Boot <bootc@bootc.net>, lkml <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111222075830.GR6348@secunet.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 22 d=C3=A9cembre 2011 =C3=A0 08:58 +0100, Steffen Klassert a =C3=
=A9crit :
> On Thu, Dec 22, 2011 at 08:51:17AM +0100, Eric Dumazet wrote:
> >=20
> > Prior to 618f9bc74a0, we were calling=20
> >=20
> > static inline u32 dst_mtu(const struct dst_entry *dst)
> >  {
> >        u32 mtu =3D dst_metric_raw(dst, RTAX_MTU);
> >=20
> >        if (!mtu)
> >                mtu =3D dst->ops->mtu(dst);
> >=20
> >        return mtu;
> > }
> >=20
> > with dst =3D fake_rtable
> >=20
> > and we did :
> >=20
> > dst_init_metrics(&rt->dst, br_dst_default_metrics, true);
> >=20
> > so dst_metric_raw(dst, RTAX_MTU) was returning 1500
> >=20
> > So bug is new, we dont need to backport this fix.
> >=20
>=20
> Ok, I see. Thanks for pointing it out!

You're welcome.

By the way we no longer have this 1500 hard coded, not sure it it
matters or not, but it looks better anyway.
