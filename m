From: Johannes Berg <johannes@sipsolutions.net>
Subject: RE: [patch] d80211: use pfifo_qdisc_ops rather thand80211-specific
	qdisc
Date: Thu, 02 Nov 2006 17:43:57 +0100
Message-ID: <1162485837.16971.5.camel@johannes.berg>
References: <C86180A8C204554D8A3323D8F6B0A29F018B5DE3@dhost002-46.dex002.intermedia.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-sQJykgStCQR/UCpYgn8m"
Cc: Christoph Hellwig <hch@infradead.org>,
	James Ketrenos <jketreno@linux.intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Jeff Garzik <jeff@garzik.org>,
	Patrick McHardy <kaber@trash.net>,
	David Kimdon <dwhedon@devicescape.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:24997 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1752026AbWKBQpt
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Nov 2006 11:45:49 -0500
To: Simon Barber <simon@devicescape.com>
In-Reply-To: <C86180A8C204554D8A3323D8F6B0A29F018B5DE3@dhost002-46.dex002.intermedia.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-sQJykgStCQR/UCpYgn8m
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2006-11-02 at 08:33 -0800, Simon Barber wrote:
> There are many reasons to have the master device - and many reasons not
> to get rid of it. The only excpetion is when using a limited fullmac
> card.  Some fullmac cards only support a single ethernet interface, so
> for these cards a single device may be OK, if we want to allow multiple
> different appearences for different types of card (a bad thing in my
> book). (Note - older prism 54g fullmac cards support WDS, hence need
> multiple interfaces).
>=20
> The master interface represents the physical networking device that
> works using native 802.11 frames. The qdisc works on 802.11 frames - not
> ethernet, and it can change how 802.11 management frames are queued. It
> can only be got rid of in the case of a fullmac card with only a single
> interface, where all management frames are processed in the card.
>=20
> In addition as we move to make 802.11 devices native (i.e. create an
> 802.11 protocol) the 802.11 master interface will be essential.

While these are good points, I don't believe having the master interface
as a *netdev* is essential. In fact, it now has no functionality as a
netdev, if you try routing packets over it they're simply dropped.

Of course we need some notion of the wireless PHY and cfg80211
explicitly represents that by assigning a wiphy index, but there's no
need for it to be a netdev.

johannes

--=-sQJykgStCQR/UCpYgn8m
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUARUogTKVg1VMiehFYAQLWvQ/+KAVshLFFiIQnlLEmjtMI4mt9Di6X9Hzh
fJ3npkvxVibrem8fntYG9hvi1XnIntsPCHuNWvSCZUosGMo0chYRAnaJp8BfJV/B
OHP5p1Zd0i0p9cjEAamscnsutjRBS9hEVCWs+PZcrPIRPX+QEsTVqB953g/IjxbN
RF4vIq7JZ92a475s7jqKmxGEIqb+wzaHx/WYibnrNue0i2pkoFwjlPnokv+jlH1b
UhlOyejw4WxivsQ6f1C59nT8z0pX5avdRaxc8JYfeRyIM38XRcpbr0hSquK54wKN
vz7DXNZ4KeXjSePWZrftiJer1KHVzeobCT1g4alN+P0oDywDksn7pkjzWkbKiZM7
qVKuvUA1OMYx8vG1FC+W+h1VFVuK5vDMfiCpJodnRlI6H1ss1QVrBS5zDDFZGFwl
3Tfj9SZGOh4MLWd30UAJPnVg9fk5d/UoeAPtvV7MgqMkRwlXjX0nmt60tKFkJJ4S
MtxM/cuQlPpiwDciQzvGOWret9Il6hK2YtKszqY3K39kZir5yRgrNSv2oNtnnQHy
j6eGI66OBy4Yd8bqWOGDY3Jv4Iwi8ZNl8f9tZbYtUbjBtgc70Gf1FVs9IrA+rnln
miLcahKvdn8YzXaLwCocPLD2fA4iEYuwkQ/3taT+A5UfvRFKQJFEx2dn1wDFP2Vz
vJP7rkNpQyA=
=mjK2
-----END PGP SIGNATURE-----

--=-sQJykgStCQR/UCpYgn8m--

