From: Antonio Quartulli <antonio@meshcoding.com>
Subject: Re: [PATCH net] netpoll: linearize skb before accessing its data
Date: Tue, 22 Oct 2013 08:06:35 +0200
Message-ID: <20131022060635.GF1544@neomailbox.net>
References: <1382391080-1607-1-git-send-email-antonio@meshcoding.com>
 <20131021.182319.625146263287554088.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
	protocol="application/pgp-signature"; boundary="ni93GHxFvA+th69W"
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.neomailbox.net ([178.209.62.157]:24136 "EHLO
	s3.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750874Ab3JVGHP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Oct 2013 02:07:15 -0400
Content-Disposition: inline
In-Reply-To: <20131021.182319.625146263287554088.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--ni93GHxFvA+th69W
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon, Oct 21, 2013 at 06:23:19PM -0400, David Miller wrote:
> From: Antonio Quartulli <antonio@meshcoding.com>
> Date: Mon, 21 Oct 2013 23:31:20 +0200
>=20
> > __netpoll_rx() assumes that the data buffer of the received
> > skb is linear and then passes it to rx_hook().
> > However this is not true because the skb has not been
> > linearized yet.
> >=20
> > This can cause rx_hook() to access non allocated memory
> > while parsing the received data.
> >=20
> > Fix __netpoll_rx() by explicitly linearising the skb.
> >=20
> > Signed-off-by: Antonio Quartulli <antonio@meshcoding.com>
>=20
> It is rx_hook's obligation to access the SKB properly and not
> assume that the SKB is linear.  It is very expensive to
> linearize every SKB just for the sake of improperly implemented
> receive hooks.
>=20
> In particular the rx hooks must make use of interface such
> as pskb_may_pull(), just like every other protocol does
> on packet input processing, to make sure the area they want
> to access is in the linear area.
>=20

But rx_hook() does not receive any skb:

609                 np->rx_hook(np, ntohs(uh->source),
610                                (char *)(uh+1),
611                                ulen - sizeof(struct udphdr));

it just receives a pointer to the data and can't do anything to make it lin=
ear.
(uh is a pointer to the udp header). Am I missing something?


Regards,

--=20
Antonio Quartulli

--ni93GHxFvA+th69W
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJSZhXrAAoJEADl0hg6qKeOjy0P/Ra7KpOqSwcgVN+X84Nk0nD9
I3HlM7VyndTYrqrj6sYO8F3x3SKB51r1GHcP9CxWbHthnHYt7Y4PnJHUHlLU44wr
a7euUsJcqR5ZB644ttK2cWesiHFumyQsw1Q5BO3YbuCEK0lY4v4gQYofZ7ymF6yj
kHNWnLXi3Ei9k2kahQGu/6GeKmp2QOdFMfo9B/TWi++0ZfaFDY3/ZV8EK2XpMTho
T3Ls52upK69pF9niFABOR/7hPfJt0gPXdraCy7Ff5LOP74YsNVEIwGcTXtKwJq8L
tD0bKr94FkMK/Vj7ORVqT8G7ipn0pzZd5k2w9ESIgZYjoQmEoGRrLhkBzVW9HjZN
NaMdkU+d/kAR20XowTsGv6pqVXo44kL4B1FOlhxPgJhmLmVLC0kRbg1bYNnkmdJ4
2vjGeXdwpKFAOwjVM0gE6O3QnxUmDvXYTBw4HQnTjpUHBdALkqLIPfYtetPqs20z
814LzfCf+gMUEy0XNzWTT9osb6FClUR/0fOFINkFiFBbNZ8qrAoDlOf4icjOYLOm
97HV1/AoXFeLWIIGpFL7+VDAwqU6itMvU2slNtlgYBkyFgIPorv/L1bBWxKbN0WH
ItQz247RXxmq769wL8+PmNpoIvrNYE6SK8Fpm90T7sw6XwRw6YX9haumJzKtW78G
RZKPkLB0DdEv1fu076a3
=77eI
-----END PGP SIGNATURE-----

--ni93GHxFvA+th69W--
