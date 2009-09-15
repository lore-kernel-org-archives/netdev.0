From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: alloc skb based on a given data buffer
Date: Tue, 15 Sep 2009 08:30:31 -0700
Message-ID: <1253028631.23427.55.camel@johannes.local>
References: <1253003420.7549.51.camel@debian>
	 <20090915.013321.07006714.davem@davemloft.net>
	 <1253005050.7549.58.camel@debian>
	 <20090915.020903.93643290.davem@davemloft.net>
	 <1253006111.7549.61.camel@debian>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha1"; protocol="application/pgp-signature"; boundary="=-fzAflWusSa20Mep4aX4E"
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"mel-wPRd99KPJ+uzQB+pC5nmwQ@public.gmane.org" <mel-wPRd99KPJ+uzQB+pC5nmwQ@public.gmane.org>,
	"Chatre, Reinette" <reinette.chatre-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"elendil-EIBgga6/0yRmR6Xm/wNWPw@public.gmane.org" <elendil-EIBgga6/0yRmR6Xm/wNWPw@public.gmane.org>,
	"Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org" <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	"linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	"penberg-bbCR+/B0CizivPeTLB3BmA@public.gmane.org" <penberg-bbCR+/B0CizivPeTLB3BmA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"ipw3945-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org"
	<ipw3945-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>,
	"akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org" <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	"cl-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org" <cl-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	"Krauss, Assaf" <assaf.krauss-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"Abbas, Mohamed" <mohamed.abbas-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Zhu Yi <yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1253006111.7549.61.camel@debian>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-fzAflWusSa20Mep4aX4E
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2009-09-15 at 17:15 +0800, Zhu Yi wrote:
> On Tue, 2009-09-15 at 17:09 +0800, David Miller wrote:
> > From: Zhu Yi <yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> > Date: Tue, 15 Sep 2009 16:57:29 +0800
> >=20
> > > Thanks. So we can put the 8K buffer into 2 skb_shinfo()->frags[] slot=
s
> > > and set nr_frags to 2, right? Is this supported allover the network c=
ode
> > > already? At a first glance, I didn't find any frags handling in mac80=
211
> > > stack.
> >=20
> > You have to pre-pull the link level protocol headers into the
> > linear area, but that's it.
> >=20
> > Again, see niu.c for details, it does:
> >=20
> > static void niu_rx_skb_append(struct sk_buff *skb, struct page *page,
> > 			      u32 offset, u32 size)
> > {
> > 	int i =3D skb_shinfo(skb)->nr_frags;
> > 	skb_frag_t *frag =3D &skb_shinfo(skb)->frags[i];
> >=20
> > 	frag->page =3D page;
> > 	frag->page_offset =3D offset;
> > 	frag->size =3D size;
> >=20
> > 	skb->len +=3D size;
> > 	skb->data_len +=3D size;
> > 	skb->truesize +=3D size;
> >=20
> > 	skb_shinfo(skb)->nr_frags =3D i + 1;
> > }
> >=20
> > to add pages to SKBs and then at the end it goes:
> >=20
> > 	skb_reserve(skb, NET_IP_ALIGN);
> > 	__pskb_pull_tail(skb, min(len, NIU_RXPULL_MAX));
> >=20
> > Right before giving the SKB to the networking stack.  NIU_RXPULL_MAX
> > should be a value that will be large enough to cover the largest
> > possible link level header.
>=20
> I see. Thanks for this info. I'll try implementing the same for iwlagn.

Hold, mac80211 can't cope with that at this point for sw crypto and
possibly other things.

johannes

--=-fzAflWusSa20Mep4aX4E
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----

iQIcBAABAgAGBQJKr7MTAAoJEODzc/N7+QmaQLwP/1psaHMJvQwqhroEfiUvI1lL
kHDoeGDMCTed8tnZ3d8OfyEOlzINTnRxP0TsAo+jrkpL6fq6LuS7ZzuHwSI3yi3m
CxY7/9Lssp+0AstkiZTPKRLAbHp2UfDxE+pr24eDH3al3gLhUNm1QmhOv9gHCsrR
gIlIPI661po9bIzYFywA+LOSEsL4aaRugfQNArSUtHgBPTWIb8l8u5v0+hg1Y89P
z9J7sMh0WcJ1gUdiL6pD+2iPL1aM8kRq05AxpXCPy4swEFoPD89wjyM+0W3SZL4s
JsG9ropdJDO12tEQp+4MoQYQPX+eIcLgyWSV+kYMUZu6ggvR9LV5544BCqnr8tq9
ogCbbOEb9tm7BFCV9dNC6FXrMfg3yPheUP6hYwo00mfE/Brjwy64fIOrXHeTK4Gw
RmZTwndT0TaBwPcIFi6Mus+GyKOP3+35RFHWLPg99ev78xTpvRZ2PjPZ8IJRLsYF
UnEcCJZBRWelgHj4iZtDI3pyRQ5zx+rS//8NT9om15vSdbSGNJ0aZG5ox0pXC5uv
kGVGnmBr/V3Cjtb7W3NIHz0LQJwJqIsClEmVha0bjXc7tU9Fby0W09naFpWZKyFX
9t7PwP4D7DCKdhmKID6qDmoqnDBNjJhdDnHO9b199BaJju0f2qZzLvDXwEvlCBso
wb/AjDoqeQE/97V5pipl
=s1h9
-----END PGP SIGNATURE-----

--=-fzAflWusSa20Mep4aX4E--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
