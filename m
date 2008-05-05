From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: [RFC v2] mac80211: assign needed_headroom/tailroom for netdevs
Date: Tue, 06 May 2008 01:23:55 +0200
Message-ID: <1210029835.8012.30.camel@johannes.berg>
References: <1210021066.4181.41.camel@johannes.berg>
	 <20080505.153730.186617868.davem@davemloft.net>
	 <1210027447.8012.15.camel@johannes.berg>
	 <20080505.161458.46071527.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-GpBbEZhH4YPp3KVAxfc8"
Cc: tomasw-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080505.161458.46071527.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-GpBbEZhH4YPp3KVAxfc8
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Mon, 2008-05-05 at 16:14 -0700, David Miller wrote:

> > Right, that makes sense. But will it ever return false? skb_cloned()
> > returns true often enough, and we only accept linear skbs, but I think =
I
> > don't understand yet what skb_header_cloned() vs. skb_cloned() refers
> > to. Which exactly is the header space I'm allowed to modify when
> > skb_header_cloned() returns false?
>=20
> skb_header_cloned() will return false always if the buffer is not
> cloned.

Right, it's less than skb_cloned().

> If it is cloned, it makes sure the data reference count allows
> for modification of the buffer.

Which buffer? skb->data..skb->tail? And isn't that, in mac80211's case,
at least currently all the buffer anyway?

> For normal traffic, you should see skb_header_cloned() always return
> false unless a network tap like tcpdump is registered.

Interesting point. I'll have to see when socket filters are run,
wpa_supplicant could have a tap open I think. Maybe that's why I'm
seeing so many cloned packets. I think I'll stacktrace skb_clone and
print that out.

johannes

--=-GpBbEZhH4YPp3KVAxfc8
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUASB+XCqVg1VMiehFYAQKp1RAAhlAKc45MkvYo7TK4dhGkzjQVTn3B9dLO
4MBPAvyL1Bphsf/AWIVVwcJOuGhy9SRGLmE4bpAq+rsN4IGQoFKmQDEMo+NH4dXG
50TPuEHnQu5r+ti+NlvcFW72HR5RtPoQ5jz/9/rlYEBrhez/FjbJWRcmcSqC06ke
qsvtuSZVMtC+7f5A3WL5MwPnrbHw2o6uvTLgsRHHO4xdzmX4wVaet+Eqw6e4eGV6
DtjVWd4whKoQOumQTegGJI1lMAK8pQfGSrTX67acvbcfWmf2MUaa7Y+s1fVgMMkp
BxZBOqVLvrrnQRYpbnIcM8vVQxZ8KDkIJbzcdUjjHAc6p/3yc34mpFdPUvf3wGyt
aqR3wAKWgN42nVbX42rRbm5FnClJpT3WMOPh5Rw4LR1Mn1+TiOJxBxH4s5GX4iXK
ybBCO/4DjrWEsgwpdNVYjB0DuJWHknJtNqoGOZJy0xAKtF2W02siXKGWwJGaXqMw
iHlxTq/CV5J8wrjmondlJNqVGYSck2ilnYn4/R4ED9aTH7HcH9IorTYGjQRESYv7
pZbE9h2wYHb6uXOXVaKhL44npkc+CTx07oK9CEfpI1bPV7D8nCzo3UfuCzYFsVb5
BODxFGnGxPaILbXpqKe3xh/rZPrsORNdGqXpMKLYKH+snYoEY3DWDTm7yipbsoIR
/sdtKOKkyHo=
=RhVy
-----END PGP SIGNATURE-----

--=-GpBbEZhH4YPp3KVAxfc8--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
