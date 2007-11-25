From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: Re: wireless vs. alignment requirements
Date: Sun, 25 Nov 2007 12:00:28 +0100
Message-ID: <1195988428.4149.225.camel@johannes.berg>
References: <E1IvoID-0006aR-00@gondolin.me.apana.org.au>
	 <1195893216.4149.186.camel@johannes.berg>
	 <20071124133200.GA27531@gondor.apana.org.au>
	 <1195912176.4149.194.camel@johannes.berg>
	 <20071124141319.GA27819@gondor.apana.org.au>
	 <1195938799.4149.197.camel@johannes.berg>
	 <20071125014446.GA32104@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-lmnqcjJjsO/mKSlP0rNb"
Cc: dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20071125014446.GA32104-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-lmnqcjJjsO/mKSlP0rNb
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable


> Sorry I was wrong about the 8 bytes requirement.  Although the
> IPv6 protocol does try to maintain an 8-byte alignment the Linux
> stack never does anything that requires that.
>=20
> So 4 bytes is enough.

Whew. Good to hear.

> However, the wireless core is definitely not out of the woods.
> It needs to support variable hardware header lengths that are
> not always a multiple of 4.
>=20
> So here's my suggestion.  Modify the wireless core to fix up any
> packets which aren't aligned correctly.  That should make it
> work albeit in a way that's less than optimal.

Not sure. On the one hand, yeah, that's something we should probably do,
on the other hand this will suck because for most drivers either nothing
needs to be done or the fixup is trivial. I suppose we should do this
but stick in a WARN_ON_ONCE() or something, at least with mac80211 debug
enabled.

Also, we do plan to run these things on rather smallish embedded devices
like APs that receive a lot of frames from many stations, and with 11n
we're pushing speeds up by quite a bit. I'm wary of putting more code
into the generic receive path.

> Then for each driver where you care about this performance
> (seriously I wouldn't for the speeds these things run at :),
> pick the most common wireless hardware header length and have
> the IP (or any other upper-level protocol) header aligned to
> at least 4 bytes.  Or better if you know what hardware header
> length that you're going to get (e.g., based on what mode you're
> in) then do the skb_reserve accordingly.

Well, you can receive non-QoS frames even in QoS or WPS frames in any
other mode etc. so you can't really make any promises as which will be
more common. Bu in practice all (sane) hardware makes sure things are
aligned properly.

> It's a good thing these things aren't running at 10Gb :)

For sure!

johannes

--=-lmnqcjJjsO/mKSlP0rNb
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUAR0lVy6Vg1VMiehFYAQJWahAAg43ceUdfYChR+OLN8pTbP0HNEp4cVuJo
lanGFW2p2XSgXlreleZHYYNUQ3DEoJdiM1reaYK5pjrY+PTj1xM51PqGlljk3A9D
ktuHTmytOIA9Q2cgkVHzT7sPy3RZZ2l4BX7TBTJQYMIukxTYPrukFHK6N19lROC8
1WV8S1/WOAYRRwHVHdN311YIgsUDbiK7pHe2d5vSYKrQM39BQ+HVO3qdah9XHlBc
m6YtJzjLRnCNqgnaOunobqh+s770NwWvo5UZ+r5GJFBsXOEOgoJ7ccOxfRJSUjxT
8wPlBYd2ZUy+L1YNgmHeKUWnmn7LYlH+ekrXfIq+LwWjn0FW2Y8gcUR/m2JXWyut
uxyfmNJSknrgoormRpdD1nr/9uOAwp/LAjfOyZmNb17fbF31H82dWWvfeWP4HuYG
wVIWYfP67Xt70qEzb3Qp6onErxuJmP4KZMCIllInLjzgC12OymySSSzKIlEIZfwM
1kWx+qCZFZDBvlP/lbhi4HkBkicU8TQpTZAmvhO3hkYJZZlgg0L/jS1fz2HfWKBR
kXI3ujKX9c17BvsG+i+Svjrp29zLK0QJKt8+vpCvcXwTx0Cf54q5OUEPaP+MoNz+
GX5l5RIPdHSQZ2Hn/fJfKK66yr7MwdIRyQP1LuXxU/ppw2bpzUK9G4FQMQzEFX4L
uPAnOBeN37g=
=yRE7
-----END PGP SIGNATURE-----

--=-lmnqcjJjsO/mKSlP0rNb--
