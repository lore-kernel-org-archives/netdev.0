From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [RFC v2] mac80211: assign needed_headroom/tailroom for netdevs
Date: Tue, 06 May 2008 01:30:30 +0200
Message-ID: <1210030230.8012.35.camel@johannes.berg>
References: <1210000923.8245.26.camel@johannes.berg>
	 <20080505.160328.203996832.davem@davemloft.net>
	 <1210029435.8012.25.camel@johannes.berg>
	 <20080505.162424.176435653.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-PE7B3CToncZ0OpRA0gfQ"
Cc: tomasw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080505.162424.176435653.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-PE7B3CToncZ0OpRA0gfQ
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, 2008-05-05 at 16:24 -0700, David Miller wrote:

> > Also, should there be some sort of timer that resets the rx_alloc_extra
> > again so that when you bridge it once with p54 (needs heaps of headroom=
)
> > you don't suffer forever?
>=20
> We're talking about, what, up to 128 bytes or something like that?
> If you're bridging over your wireless device you've already invested
> in assuming those kinds of costs.

About that much at most, yeah. But if you then decide that you don't
want to bridge wireless after all... anyway doesn't matter, was just a
thought.

> I don't think this aspect is really worth worrying about.  The current
> behavior is so much incredibly worse. :-)

That's true.

> > > @@ -255,11 +255,12 @@ struct sk_buff *__netdev_alloc_skb(struct net_d=
evice *dev,
> > >  		unsigned int length, gfp_t gfp_mask)
> > >  {
> > >  	int node =3D dev->dev.parent ? dev_to_node(dev->dev.parent) : -1;
> > > +	unsigned int extra =3D dev->rx_alloc_extra + NET_SKB_PAD;
> > >  	struct sk_buff *skb;
> > > =20
> > > -	skb =3D __alloc_skb(length + NET_SKB_PAD, gfp_mask, 0, node);
> > > +	skb =3D __alloc_skb(length + extra, gfp_mask, 0, node);
> > >  	if (likely(skb)) {
> > > -		skb_reserve(skb, NET_SKB_PAD);
> > > +		skb_reserve(skb, extra);
> >=20
> > Doesn't that break alignment though?
>=20
> Good catch, we'll have to align the rx_alloc_extra to some modulus or
> similar.  Ideally, at the spot where rx_alloc_extra is set instead
> of here.

Yeah, it just has to be a multiple of four I think.

johannes

--=-PE7B3CToncZ0OpRA0gfQ
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUASB+YlaVg1VMiehFYAQK9NQ/7BzlWhapNyQ+zLLD6dcM9vu8hz9U8kBgV
yM4j0GtxlODprgkcSDY7eIkg2BaIV9Gj4X5iRJi8VSsaYd7wSN7smEvxIPg4rIuD
uC8mbOKCEnSSG/yXXiyiiAgN9nCNsr63OO+qaiEdxcwOwqHPZ7AxbrZzeyLo7mXw
eQpRQS5nMQVERTG/bopT8yB5UiZ//jnYVjMRSY9+Il1HpD1QwQBKDxsg3DxtgbVm
tvxmQSSBDeNa+E/fZlQGELfjJbJ2yft3MVIFrSAvGA5wJno9qAPUJUlgd/JuFGzt
kOA5bN2QJOi24r0FU6fta85DqkDbSgn3YmRCtVxfDqdDyjLTgODosTCImk8T8Rzt
NKTbfZwEMy7aQ0CUOaWU0YR+D01I1WVjupwMZ6ZfL66XsOVIUC6KxxRBHW8csAqC
Wa8AwmGakLKb1rpNs9lflpR/CPymFOjFKCPH+cAPdKZfpeLJsivuGsuMTNxcY/4c
a+FMgnZFUI2Sogg1n1ShenTOWUC/9QrfYmN4qs3TITHrccvrprW63p8K+QP6eZGd
tgfJAb+ediSUb0OHTGCnsY7vwH3dlDaNm0CLf8JHKMXHcsZCCzXtnGyud8KsKhhj
CpV8tZE9cjvJIab31q7gAcysomRbAV1YPJxP8uf+joKXd34Mosw+w0wzD9m07EP7
a4/41NO6M4A=
=fvj7
-----END PGP SIGNATURE-----

--=-PE7B3CToncZ0OpRA0gfQ--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
