From: Ian Kumlien <pomac@vapor.com>
Subject: Re: [PATCH] sky2: jumbo frame regression fix
Date: Wed, 03 Oct 2007 03:34:34 +0200
Message-ID: <1191375274.26233.17.camel@localhost>
References: <1191372129.26233.12.camel@localhost>
	 <20071002180209.47c350a3@freepuppy.rosehill>
Reply-To: pomac@vapor.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-nM+280Pv6eZit1SAcsnS"
Cc: Jeff Garzik <jgarzik@pobox.com>, Linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from proxy3.bredband.net ([195.54.101.73]:50156 "EHLO
	proxy3.bredband.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756627AbXJCBes (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Oct 2007 21:34:48 -0400
In-Reply-To: <20071002180209.47c350a3@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-nM+280Pv6eZit1SAcsnS
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On tis, 2007-10-02 at 18:02 -0700, Stephen Hemminger wrote:
> Remove unneeded check that caused problems with jumbo frame sizes.
> The check was recently added and is wrong.
> When using jumbo frames the sky2 driver does fragmentation, so
> rx_data_size is less than mtu.

Confirmed working.

Now running with 9k mtu with no errors, =3D)

It also seems that the FIFO bug was the one that affected me before,
damn odd race that one.

> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
Tested-by: Ian Kumlien <pomac@vapor.com>

(if that tag exists now)

Btw, Sorry but all mail directly to you will be blocked. I have yet to
fix the relaying properly with isp:s blocking port 25 etc so for some of
you this mail will only show up on the ML.

> --- a/drivers/net/sky2.c	2007-10-02 17:56:31.000000000 -0700
> +++ b/drivers/net/sky2.c	2007-10-02 17:58:56.000000000 -0700
> @@ -2163,9 +2163,6 @@ static struct sk_buff *sky2_receive(stru
>  	sky2->rx_next =3D (sky2->rx_next + 1) % sky2->rx_pending;
>  	prefetch(sky2->rx_ring + sky2->rx_next);
> =20
> -	if (length < ETH_ZLEN || length > sky2->rx_data_size)
> -		goto len_error;
> -
>  	/* This chip has hardware problems that generates bogus status.
>  	 * So do only marginal checking and expect higher level protocols
>  	 * to handle crap frames.
--=20
Ian Kumlien <pomac () vapor ! com> -- http://pomac.netswarm.net

--=-nM+280Pv6eZit1SAcsnS
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.7-ecc0.1.6 (GNU/Linux)

iD8DBQBHAvGq7F3Euyc51N8RAlTkAJ9c3Ed1FAB1zSNH+e3YzO4gfWul5wCePAU/
GqxZqXFL0c3bCZZKHM7FCXo=
=YnCL
-----END PGP SIGNATURE-----

--=-nM+280Pv6eZit1SAcsnS--

