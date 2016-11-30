From: Pavel Machek <pavel@ucw.cz>
Subject: Re: stmmac ethernet in kernel 4.4: coalescing related pauses?
Date: Wed, 30 Nov 2016 11:28:57 +0100
Message-ID: <20161130102857.GA14296@amd>
References: <20161123105125.GA26394@amd>
 <f14255ee-7fa8-afef-23ec-fc4f9a74eec8@marvell.com>
 <20161128.095431.856183735501262965.davem@davemloft.net>
 <1480347103.18162.58.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="HlL+5n6rz5pIUxbD"
Cc: David Miller <davem@davemloft.net>, lsanfil@marvell.com,
        peppe.cavallaro@st.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1480347103.18162.58.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--HlL+5n6rz5pIUxbD
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Mon 2016-11-28 07:31:43, Eric Dumazet wrote:
> On Mon, 2016-11-28 at 09:54 -0500, David Miller wrote:
> > From: Lino Sanfilippo <lsanfil@marvell.com>
> > Date: Mon, 28 Nov 2016 14:07:51 +0100
> >=20
> > > Calling skb_orphan() in the xmit handler made this issue disappear.
> >=20
> > This is not the way to handle this problem.
> >=20
> > The solution is to free the SKBs in a timely manner after the
> > chip has transmitted the frame.
>=20
> Note that the 'pauses' described by Pavel are also caused by a too small
> SO_SNDBUF value on the UDP socket.
>=20
> An immediate fix, with no kernel change is to increase it.
>=20
> echo 1000000 >/proc/sys/net/core/wmem_default

Thanks a lot. For the record, that works around the problem, too. (Or
at least helps a lot; it may be possible that problem still remains if
continuous stream of packets is going to trigger this, if I read the
sources correctly.)

Best regards,
									Pavel
--=20
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blo=
g.html

--HlL+5n6rz5pIUxbD
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlg+qekACgkQMOfwapXb+vKB8gCcDZGH6W4A5WADPi/NDNgf9RfF
RWcAn0gyWtVoGTpGzrtbo23spNXbheYp
=NrBz
-----END PGP SIGNATURE-----

--HlL+5n6rz5pIUxbD--
