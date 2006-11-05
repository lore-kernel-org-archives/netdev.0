From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 0/11] convert d80211 to a proper protocol
Date: Sun, 05 Nov 2006 18:06:44 +0100
Message-ID: <1162746405.24574.31.camel@johannes.berg>
References: <1162741174.24574.22.camel@johannes.berg>
	 <200611051754.34099.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-rt1fZHbqq5HqCtuQSVWv"
Cc: netdev <netdev@vger.kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>, Jouni Malinen <jkm@devicescape.com>,
	Simon Barber <simon@devicescape.com>,
	Hong Liu <hong.liu@intel.com>,
	Michael Wu <flamingice@sourmilk.net>,
	Michael Buesch <mbuesch@freenet.de>,
	David Kimdon <david.kimdon@devicescape.com>,
	James Ketrenos <jketreno@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:18053 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1161363AbWKERII
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Nov 2006 12:08:08 -0500
To: Ivo van Doorn <ivdoorn@gmail.com>
In-Reply-To: <200611051754.34099.IvDoorn@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-rt1fZHbqq5HqCtuQSVWv
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

Hi,

> Previously the open() and stop() methods in ieee80211_hw had been
> deprecated and the driver should enable or disable the radio
> based on the add_interface and remove_interface() functions.
> Now that the driver should provide open() and stop() for the netdevice
> structure does this mean that these 2 methods are back in control
> for enabling and disabling the radio?

Yeah, it'll have to, otherwise the device it created itself will be
totally useless unless some other device is also open.

> And if so what should the
> add_interface and remove_interface, should they be only in charge of
> triggering some configuration changes (like mode and mac address)?

Mostly notably it's probably going to be used for the drivers to have
veto powers, if they can't handle some specific combinations etc.

Though for 802.11h the radio does need to be turned off in some cases
regardless of the up/down state, so we'll have to think about that. Or
we just force all interfaces down? Not sure yet.

I confident we can work out these issues if we agree that converting it
to a protocol is a good thing. After doing it, I'm personally pretty
convinced that it is, some things just fell into place nicely and feel
less hacky.

johannes

--=-rt1fZHbqq5HqCtuQSVWv
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUARU4aI6Vg1VMiehFYAQIBSxAAn4cOeCRdkDjwnJ3qdwqHSxe7B9Xae0Dx
rorZGMaNqa16am1R+1+qDLC6QZBP2WT2JzBnCZzV5VBpD2Mptb0roz4dtML82yUq
lwI1NzKaa8y6mf6vYMVp6mhi4lDSITSF12IF/PkGrNtx++4/iy5JElIxw+ucNe8J
GDt6cTH6aUCfLiLxaFHovxKDcq9/3uJmaic0jFYtl/Un4NGXoHnpqu9uVKkZ+DkC
dGFzj6XHZt4M4GDicYCevUGfBSscaDcBfze4sV1wDUiIV4uRYgWnuF7GEsunM5CB
8VQeZElzN+0nxLke4k/9QZVIFcb5whWEkSkf+OImugMHgHne2v9sZ9VXsD9EErWU
x11bDSn/wy5j14JPQ1lcxx+m05cWDozmAzA+uGDETiNgZz86xO9BnV8zWlriloe1
aJrIQj5g2IVDkxPeNDnGkK+WUGrcqXuJuMMfsMjegQVxt9xQMnEHS6V/1zrZxdVs
EYsPctVmpU62RAudpI2+gdyuXNHI9m0chfdeNNb+LNLR2pN7gUXWruub8WegeKRU
kFpY2rSpOHfHM5XDp1YsczRJfsUP9FRsMQe85CPTMurvkq2rS7diJBkbIjt/molV
d4NJWo8lmdkZWcz69NlGp5P4LWYR6ZmKXUXcekSNRtWdJEw15/dGCfVy4rYrLxac
rhoSP5tYbIM=
=u5He
-----END PGP SIGNATURE-----

--=-rt1fZHbqq5HqCtuQSVWv--

