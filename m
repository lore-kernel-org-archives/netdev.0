From: Harald Welte <laforge@gnumonks.org>
Subject: Re: [E1000-devel] Transmission limit
Date: Sat, 27 Nov 2004 10:25:03 +0100
Message-ID: <20041127092503.GA12592@sunbeam.de.gnumonks.org>
References: <1101467291.24742.70.camel@mellia.lipar.polito.it> <41A73826.3000109@draigBrady.com> <1101483081.24742.174.camel@mellia.lipar.polito.it>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="mYCpIKhGyMATD0i+"
Cc: P@draigBrady.com, e1000-devel@lists.sourceforge.net,
        Jorge Manuel Finochietto <jorge.finochietto@polito.it>,
        Giulio Galante <galante@polito.it>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Marco Mellia <mellia@prezzemolo.polito.it>
Content-Disposition: inline
In-Reply-To: <1101483081.24742.174.camel@mellia.lipar.polito.it>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--mYCpIKhGyMATD0i+
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Nov 26, 2004 at 04:31:21PM +0100, Marco Mellia wrote:
> If you don't trust us, please, ignore this email.
> Sorry.
>=20
> That's the number we have. And are actually very similar from what other
> colleagues of us got.
>=20
> The point is:
> while a PCI-X linux or (or click) box can receive (receive just up to
> the netif_receive_skb() level and then discard the skb) up to more than
> wire speed using off-the-shelf gigabit ethernet hardware, there is no
> way to transmit more than about half that speed. This is true
> considering minimum sized ethernet frames.

Yes, I've seen this, too.

I even rewrote the linux e1000 driver in order to re-fill the tx queue
=66rom hardirq handler, and it didn't help.  760kpps is the most I could
ever get (133MHz 64bit PCI-X on a Sun Fire v20z, Dual Opteron 1.8GHz)

I've posted this result to netdev at some earlier point, I also Cc'ed
intel but never got a reply
(http://oss.sgi.com/archives/netdev/2004-09/msg00540.html)

My guess is that Intel always knew this and they want to sell their CSA
chips rather than improving the PCI e1000.

We are hitting a hard limit here, either PCI-X wise or e1000 wise.  You
cannot refill the tx queue faster than from hardirq, and still you don't
get any better numbers.

It was suggested that the problem is PCI DMA arbitration latency, since
the hardware needs to arbitrate the bus for every packet.

Interestingly, if you use a four-port e1000, the numbers get even worse
(580kpps) because the additional pcix bridge on the card introduces
further latency.

--=20
- Harald Welte <laforge@gnumonks.org>               http://www.gnumonks.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
Programming is like sex: One mistake and you have to support it your lifeti=
me

--mYCpIKhGyMATD0i+
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQFBqEfvXaXGVTD0i/8RAk3JAJ0bKs2zTAXAp0XqO5gFhA6kLro+VgCfckRx
iC/AOlgGi3BB5MDvTD5DqrI=
=Hplb
-----END PGP SIGNATURE-----

--mYCpIKhGyMATD0i+--
