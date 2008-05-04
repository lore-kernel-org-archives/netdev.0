From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: mac80211 truesize bugs
Date: Sun, 04 May 2008 04:22:20 +0200
Message-ID: <1209867740.6210.46.camel@johannes.berg>
References: <1209760731.3608.17.camel@johannes.berg>
	 <20080502.163334.148944203.davem@davemloft.net>
	 <1209815533.3987.21.camel@johannes.berg>
	 <20080503.180300.10562559.davem@davemloft.net>
	 <1209865354.6210.23.camel@johannes.berg>
	 <20080504020203.GA30514@gondor.apana.org.au>
	 <1209866916.6210.39.camel@johannes.berg>
	 <20080504021213.GA30660@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-u6bwjd8rB/4JZQJZajxq"
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080504021213.GA30660-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-u6bwjd8rB/4JZQJZajxq
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Sun, 2008-05-04 at 10:12 +0800, Herbert Xu wrote:
> On Sun, May 04, 2008 at 04:08:36AM +0200, Johannes Berg wrote:
> >
> > So, what is mac80211 supposed to do? It needs up to 54 bytes of
> > available headroom (for an encrypted mesh packet which currently can't
> > really happen, but anyway) yet it cannot pskb_expand_head() either.
> > Cloning each packet seems even more expensive, and just like skb_orphan
> > subverts the purpose of the socket accounting.
>=20
> If all/the majority of your packets need the space then put it in
> LL_MAX_HEADER. =20

Yes, wireless always needs at least 24 bytes, but more likely 34
(encryption+QoS). However, I just increased LL_MAX_HEADER to 54 and that
doesn't seem to have helped.

> In any case, you should always expand the packet
> if necessary in your output routine since LL_MAX_HEADER is just a
> hint.  Yes cloning is expensive compared to not having to do it,
> but as long as this is only done for the exception then it's
> irrelevant.

What's wrong with, instead, doing skb_orphan() and then
pskb_expand_head()? That seems to have the same effect.

johannes

--=-u6bwjd8rB/4JZQJZajxq
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUASB0d26Vg1VMiehFYAQIPkQ/9EPHYRMvjda0ksMSfhj1qUzhQRrCSXYuC
KVnOW2WKWP6WSK2mK9Vz+vLTvPlNsgQCqwM1kYZRZVmlcdfmTD14P/dVeZ1mBGPG
Ij2udwlUTBEnTvIoytq5leMtmJ2uPxPj3dk4nwWCFpxtpHYR6xF/8hfkro3ijZCK
9L52w05u4kJVhSXGxebL0D/xu1nBBhHugy/jPAAEeGBWE45+Z6XB3HFHs42VOo9M
Y23j2oCKNI6oB9tZ9lTXSZVlTDT6CXrt5JF17Z1h3ByLm2WhprDnG0z0blAQqOll
+azgc26ZuQwQncuvmlxv+TqhgbJNqTb6QRHzrFdSBl2rNk3A9CI1QiO/Zmh5huVf
hRb2HHhJtTfRw2XLD816POnSQf6ahnC1+uHMEcs35s5WF7PqctIQL3E9IDyc2aQx
oYY9B3fd1GFfsjdu+gZagAmxAVCFvPtDkYIuaL83+jpcLq5oSBqWRHYDVHyoW4KO
j7/+nop6aNed1x9f8wwnz36+gf4KWmoT4baYnq4kK+HsbzxY8QCdGG8xVRY40cNt
lPGi462wdKjxrWN4uCNoQ4FmwOYpkXbA7PjfaqUtmVXa1ocdTBeo49RYWVZwaq6u
R1jaWwIp6X0HpxVlgW437xRFNCPIdUtBP7p1vnR10l0QvlQy4bHCN7RIlfOx3w22
5VgOcRCxFCU=
=NEsH
-----END PGP SIGNATURE-----

--=-u6bwjd8rB/4JZQJZajxq--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
