From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: Sundance network driver (D-Link DFE-580TX) timeouts rendering
 interface unusable
Date: Mon, 30 Jan 2012 14:05:11 +0000
Message-ID: <1327932311.5400.429.camel@deadeye>
References: <SNT141-W3553B2629FBBC84A5A140596860@phx.gbl>
	 <1327205171.8004.96.camel@deadeye>
	 <SNT141-W5087B9A5022955EA5564DB96890@phx.gbl>
	 <20120126220640.GO12704@decadent.org.uk>
	 <SNT141-W58AC5ADD0BC9DE29AFA00D968E0@phx.gbl>
	 <1327811546.5400.291.camel@deadeye>
	 <CAHj3AVm8cjkj83QHGAqOji6t4uWFr6jAAADu7vLKyfEORk1LoA@mail.gmail.com>
	 <1327918447.2288.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-uAAohAXToUvC0DWtGl6I"
Cc: Denis Kirjanov <kirjanov@gmail.com>,
	"Mike ." <mike-bugreport@hotmail.com>, 656476@bugs.debian.org,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:50957 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752495Ab2A3OFT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2012 09:05:19 -0500
In-Reply-To: <1327918447.2288.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-uAAohAXToUvC0DWtGl6I
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2012-01-30 at 11:14 +0100, Eric Dumazet wrote:
> Le lundi 30 janvier 2012 =C3=A0 12:51 +0300, Denis Kirjanov a =C3=A9crit =
:
> > I'll check this out. After kernel.org was cracked I've missed
> > @kernel.org mail account.
>=20
>=20
> At first glance, start_tx() is racy against TX completion.
>=20
> It does :
>=20
>         if (np->cur_tx - np->dirty_tx < TX_QUEUE_LEN - 1 &&
>             !netif_queue_stopped(dev)) {
>                 /* do nothing */
>         } else {
>                 netif_stop_queue (dev);
>         }
>=20
> So it can call netif_stop_queue() while TX completion handler did a
> cleanup of all queued packets right before.

Yes, I spotted that.  But no descriptors are pushed to the hardware
here; that's done in the driver's TX tasklet.  Although... maybe that
can run immediately when scheduled from here?  I've never had to deal
with tasklets so I really don't know their semantics.

Ben.

> Note intr_handler() doesnt hold the queue spinlock when it does :
>=20
>                 if (netif_queue_stopped(dev) &&
>                         np->cur_tx - np->dirty_tx < TX_QUEUE_LEN - 4) {
>                         /* The ring is no longer full, clear busy flag. *=
/
>                         netif_wake_queue (dev);
>                 }
>=20
>=20
>=20

--=20
Ben Hutchings
Lowery's Law:
             If it jams, force it. If it breaks, it needed replacing anyway=
.

--=-uAAohAXToUvC0DWtGl6I
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIVAwUATyajl+e/yOyVhhEJAQrccBAAwxXUb4eevylb/PSj1IoP//L7fwS2EjTG
QVEX8sCIZAyY5X4/tq/V0vOVollOP9vV+AmgulsyFNkEjnA4RLR/FloKAsRkybFq
iCko5M7LD1eNee8DSunBooefhSeEzoVnTvsmjDYtPmPymm1JyaytKDsYHoklEwkL
3XVquILC9dgdpW6pIusrfw24EQ/WXXA0PMZTiDkhT35U72VeSLYJrrCO90tpKZ4H
GpZB7btLBqshwIvl+PEYGLrrS0CuDsbAfJUbhg2dr6sVXVfxtSxTwpI4vL9lgtab
eDx634augpoiaRQ8PlypUhgK6C1vUTTMSVwxd6W03tuRiXwKpgxWbzcX9Qm6JlNE
X8UF/zNpa7vSAoko9v81ZFMfFTqV8nJYvQD0nEAzNACVwIu6nG2FiAuhXbp88CO1
kpolDgL99WNR7H+GvEB8EM1EhoXAsTEFA1k94ZL9Zi0eBiKN46JMEPM1g126gDpb
osPAxZpxS5lwyVHo3hYTgKSpenEY1/QfmfUgcrSkD2LtFuCvT3SVkh1nZ0bBQdGg
l0ZAuTmM3xxmNfotm3d8d9IE5wft0UW9wUCuBEPIfD94cISEMhFzfg4YoLdLp7PN
ulo845i7HBWdIcpytJuh2UOQv6tQrx6ZzVyWNw08rmEFho5jUqlDBChWweARiqtQ
p2hdA4nAOFM=
=MIN1
-----END PGP SIGNATURE-----

--=-uAAohAXToUvC0DWtGl6I--
