From: Martin Josefsson <gandalf@wlug.westbo.se>
Subject: Re: [E1000-devel] Transmission limit
Date: Fri, 10 Dec 2004 17:24:12 +0100
Message-ID: <1102695852.12078.27.camel@tux.rsn.bth.se>
References: <1101467291.24742.70.camel@mellia.lipar.polito.it>
	 <41A73826.3000109@draigBrady.com> <16807.20052.569125.686158@robur.slu.se>
	 <1101484740.24742.213.camel@mellia.lipar.polito.it>
	 <41A76085.7000105@draigBrady.com>
	 <1101499285.1079.45.camel@jzny.localdomain>
	 <16811.8052.678955.795327@robur.slu.se>
	 <1101821501.1043.43.camel@jzny.localdomain>
	 <20041130134600.GA31515@xi.wantstofly.org>
	 <1101824754.1044.126.camel@jzny.localdomain>
	 <20041201001107.GE4203@xi.wantstofly.org>
	 <1101863399.4663.54.camel@sfeldma-mobl.dsl-verizon.net>
	 <16813.58484.343629.570703@robur.slu.se>
	 <1101919791.5198.15.camel@localhost.localdomain>
	 <16815.23964.93437.411404@robur.slu.se>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-GXGZyDMmSDaXyqjouBHS"
Cc: sfeldma@pobox.com, Lennert Buytenhek <buytenh@wantstofly.org>,
        jamal <hadi@cyberus.ca>, P@draigBrady.com, mellia@prezzemolo.polito.it,
        e1000-devel@lists.sourceforge.net,
        Jorge Manuel Finochietto <jorge.finochietto@polito.it>,
        Giulio Galante <galante@polito.it>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Robert Olsson <Robert.Olsson@data.slu.se>
In-Reply-To: <16815.23964.93437.411404@robur.slu.se>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-GXGZyDMmSDaXyqjouBHS
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2004-12-02 at 19:23, Robert Olsson wrote:
> Hello!
>=20
> Below is little patch to clean skb at xmit. It's old jungle trick Jamal
> and I used w. tulip. Note we can now even decrease the size of TX ring.

Just a small unimportant note.

> --- drivers/net/e1000/e1000_main.c.orig	2004-12-01 13:59:36.000000000 +01=
00
> +++ drivers/net/e1000/e1000_main.c	2004-12-02 20:37:40.000000000 +0100
> @@ -1820,6 +1820,10 @@
>   		return NETDEV_TX_LOCKED;=20
>   	}=20
> =20
> +
> +	if( adapter->tx_ring.next_to_use - adapter->tx_ring.next_to_clean > 80 =
)
> +		e1000_clean_tx_ring(adapter);
> +
>  	/* need: count + 2 desc gap to keep tail from touching
>  	 * head, otherwise try next time */
>  	if(E1000_DESC_UNUSED(&adapter->tx_ring) < count + 2) {

This patch is pretty broken, I doubt you want to call
e1000_clean_tx_ring(), I think you want some variant of
e1000_clean_tx_irq() :)

e1000_clean_tx_irq() takes adapter->tx_lock which e1000_xmit_frame()
also does so it will need some modification.

And it should use E1000_DESC_UNUSED as Scott pointed out.

--=20
/Martin

--=-GXGZyDMmSDaXyqjouBHS
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.5 (GNU/Linux)

iD8DBQBBuc2sWm2vlfa207ERAjcUAJ90ZQvLNaEHUD+XZa1vk4fQWxLUhQCfev61
Ls4tqaYcwJJpjd1D8ojBLHs=
=8w/r
-----END PGP SIGNATURE-----

--=-GXGZyDMmSDaXyqjouBHS--
