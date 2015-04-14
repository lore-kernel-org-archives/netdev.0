From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [stable regression] tcp: make connect() mem charging friendly
Date: Tue, 14 Apr 2015 20:12:47 +0100
Message-ID: <1429038767.3211.50.camel@decadent.org.uk>
References: <1428996723.3211.34.camel@decadent.org.uk>
	 <1429013996.7346.5.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-oEc7wfoa6KY9gjlXqyH0"
Cc: netdev <netdev@vger.kernel.org>, stable <stable@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>, 782515@bugs.debian.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1429013996.7346.5.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-oEc7wfoa6KY9gjlXqyH0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2015-04-14 at 05:19 -0700, Eric Dumazet wrote:
> On Tue, 2015-04-14 at 08:32 +0100, Ben Hutchings wrote:
> > Commit 355a901e6cf1b2b763ec85caa2a9f04fbcc4ab4a ("tcp: make connect()
> > mem charging friendly") was backported to various stable branches:
> >=20
> > v3.10.73: e64a85197b3f tcp: make connect() mem charging friendly
> > v3.12.40: d06381e8aac5 tcp: make connect() mem charging friendly
> > v3.14.37: 5a8e8f482b4a tcp: make connect() mem charging friendly
> > v3.18.11: e8f117f002ca tcp: make connect() mem charging friendly
> > v3.13.11-ckt19: de023863df9d tcp: make connect() mem charging friendly
> > v3.16.7-ckt9: bea5f6ef9fcb tcp: make connect() mem charging friendly
> >=20
> > On the 3.16 branch, this has resulted in a regression for TCP Fast Open=
:
> > <https://bugs.debian.org/782515>.  The BUG() at the top of
> > tcp_transmit_skb() fires as tcp_skb_pcount(skb) =3D=3D 0.
> >=20
> > tcp_send_syn_data() does:
> >=20
> > 	memcpy(syn_data->cb, syn->cb, sizeof(syn->cb));
> >=20
> > Since commit cd7d8498c9a5 ("tcp: change tcp_skb_pcount() location") thi=
s
> > is sufficient to set the GSO segment count correctly.  But in older
> > branches (< 3.18) the GSO segment count in skb_shared_info is used and
> > is no longer copied by tcp_send_syn_data().
> >=20
> > All the versions listed above, except v3.18.11, appear to have suffered
> > this regression.
> >=20
> > Ben.
> >=20
>=20
> Hi Ben
>=20
> Sorry to ear that. Have you already fixed this, or are you asking for
> help ?

That was as far as I got this morning.  I can probably come up with a
fix later if you don't sooner.

Ben.

--=20
Ben Hutchings
Editing code like this is akin to sticking plasters on the bleeding stump
of a severed limb. - me, 29 June 1999

--=-oEc7wfoa6KY9gjlXqyH0
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVS1ms+e/yOyVhhEJAQrpThAAnwSBzQDDdtcCN2uCFcuVai0wxGsS5iU5
nNVzPfeiAaF8XYfExb200ZXMS3tTlc0lh5uO44qDqL0XyeXFU3Cr7vFSWTmI/1yW
1AT6yDDr/ja0YU9b62CRQ3IesUynhEpa8XGGKD6EG0SvkWs42zw5eQBcLBQZfGtg
s99Ipd2WlXaQy3gXg+mJMQOrZgz6rYV70VmG7+6MjKl54dkDdqame1tK/ggL7gyu
iVRmH1afw/6zqEB2pllu/+kGsZu2i78AZBsyYbge5aXwWbSmiakm1W90flscJdUF
Buj5OZQDbzpw3fr7XJAfAyGhAbV6uOuUcrw1cFD3jBcPQD3XaJcbJVel3s6eHGW6
1wdi+/mAi5qc8XJyPG0x7WI6kDkne9CK+kHlw5AbtG/I1mtynjvgKZpf4EJa44lV
iX4+F3mnlb/wuvW/bWlP7TtDlinL8VvJPd01skHIJz39DjWzHQh/TA/VYAIYVTRX
6WM5B+N0aG5r9OMUhsJrZe1wVfzrK1W5H9er5ct2INc0ocMH0X8LEgkb7kYl4Z+W
rEn8Lc7cd3nVFN6zzarMq4ZsV7+KELlmKwXwkpLGLS/gPqk/6JODJXHm2P/FNwsr
cHqHno/LojnbpvIOlI07AEhNgRhWLH55EfQjRbMgZfKgEci9o1bVUcJbFZpHDxC+
7lrXdepMH7c=
=VYkZ
-----END PGP SIGNATURE-----

--=-oEc7wfoa6KY9gjlXqyH0--
