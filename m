From: Tilman Schmidt <tilman@imap.cc>
Subject: Re: [PATCH net-next] drivers/isdn/gigaset: tasklet_init - Remove
 unnecessary leading & from second arg
Date: Sat, 21 Nov 2009 19:08:14 +0100
Message-ID: <4B082C8E.2030801@imap.cc>
References: <1258660553.3863.18.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig24EDEBA3D41E64401A2F216B"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Hansjoerg Lipp <hjlipp@web.de>,
	Karsten Keil <isdn@linux-pingi.de>,
	gigaset307x-common@lists.sourceforge.net
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4.smtp.messagingengine.com ([66.111.4.28]:41942 "EHLO
	out4.smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756663AbZKUSIE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Nov 2009 13:08:04 -0500
In-Reply-To: <1258660553.3863.18.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig24EDEBA3D41E64401A2F216B
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Am 19.11.2009 20:55 schrieb Joe Perches:
> Changed function pointer use from non-majority address-of style
> to majority short form without & via:
>=20
> grep -rPl "\btasklet_init\s*\([^,\)]+,\s*\&" drivers/isdn | while read =
file ; do \
>         perl -i -e 'local $/; while (<>) { s@(\btasklet_init\s*\([^,\)]=
+,\s*)\&@\1@g ; print ; }' $file ;\
> done
>=20
> Compile tested allyesconfig x86
>=20
> Signed-off-by: Joe Perches <joe@perches.com>

Acked-by: Tilman Schmidt <tilman@imap.cc>

Thanks,
Tilman

>=20
>  drivers/isdn/gigaset/bas-gigaset.c |    4 ++--
>  drivers/isdn/gigaset/common.c      |    2 +-
>  drivers/isdn/gigaset/interface.c   |    2 +-
>  drivers/isdn/gigaset/ser-gigaset.c |    2 +-
>  drivers/isdn/gigaset/usb-gigaset.c |    2 +-
>  5 files changed, 6 insertions(+), 6 deletions(-)
>=20
> diff --git a/drivers/isdn/gigaset/bas-gigaset.c b/drivers/isdn/gigaset/=
bas-gigaset.c
> index 9fd19db..95ebc51 100644
> --- a/drivers/isdn/gigaset/bas-gigaset.c
> +++ b/drivers/isdn/gigaset/bas-gigaset.c
> @@ -2117,7 +2117,7 @@ static int gigaset_initbcshw(struct bc_state *bcs=
)
>  		return 0;
>  	}
>  	tasklet_init(&ubc->sent_tasklet,
> -		     &write_iso_tasklet, (unsigned long) bcs);
> +		     write_iso_tasklet, (unsigned long) bcs);
> =20
>  	spin_lock_init(&ubc->isoinlock);
>  	for (i =3D 0; i < BAS_INURBS; ++i)
> @@ -2138,7 +2138,7 @@ static int gigaset_initbcshw(struct bc_state *bcs=
)
>  	ubc->shared0s =3D 0;
>  	ubc->stolen0s =3D 0;
>  	tasklet_init(&ubc->rcvd_tasklet,
> -		     &read_iso_tasklet, (unsigned long) bcs);
> +		     read_iso_tasklet, (unsigned long) bcs);
>  	return 1;
>  }
> =20
> diff --git a/drivers/isdn/gigaset/common.c b/drivers/isdn/gigaset/commo=
n.c
> index c438cfc..82ed1cd 100644
> --- a/drivers/isdn/gigaset/common.c
> +++ b/drivers/isdn/gigaset/common.c
> @@ -727,7 +727,7 @@ struct cardstate *gigaset_initcs(struct gigaset_dri=
ver *drv, int channels,
>  	cs->ev_tail =3D 0;
>  	cs->ev_head =3D 0;
> =20
> -	tasklet_init(&cs->event_tasklet, &gigaset_handle_event,
> +	tasklet_init(&cs->event_tasklet, gigaset_handle_event,
>  		     (unsigned long) cs);
>  	cs->commands_pending =3D 0;
>  	cs->cur_at_seq =3D 0;
> diff --git a/drivers/isdn/gigaset/interface.c b/drivers/isdn/gigaset/in=
terface.c
> index 577809c..d2260b0 100644
> --- a/drivers/isdn/gigaset/interface.c
> +++ b/drivers/isdn/gigaset/interface.c
> @@ -584,7 +584,7 @@ void gigaset_if_init(struct cardstate *cs)
>  	if (!drv->have_tty)
>  		return;
> =20
> -	tasklet_init(&cs->if_wake_tasklet, &if_wake, (unsigned long) cs);
> +	tasklet_init(&cs->if_wake_tasklet, if_wake, (unsigned long) cs);
> =20
>  	mutex_lock(&cs->mutex);
>  	cs->tty_dev =3D tty_register_device(drv->tty, cs->minor_index, NULL);=

> diff --git a/drivers/isdn/gigaset/ser-gigaset.c b/drivers/isdn/gigaset/=
ser-gigaset.c
> index ac3409e..168d585 100644
> --- a/drivers/isdn/gigaset/ser-gigaset.c
> +++ b/drivers/isdn/gigaset/ser-gigaset.c
> @@ -434,7 +434,7 @@ static int gigaset_initcshw(struct cardstate *cs)
>  	dev_set_drvdata(&cs->hw.ser->dev.dev, cs);
> =20
>  	tasklet_init(&cs->write_tasklet,
> -		     &gigaset_modem_fill, (unsigned long) cs);
> +		     gigaset_modem_fill, (unsigned long) cs);
>  	return 1;
>  }
> =20
> diff --git a/drivers/isdn/gigaset/usb-gigaset.c b/drivers/isdn/gigaset/=
usb-gigaset.c
> index f56b2a8..3ab1dae 100644
> --- a/drivers/isdn/gigaset/usb-gigaset.c
> +++ b/drivers/isdn/gigaset/usb-gigaset.c
> @@ -614,7 +614,7 @@ static int gigaset_initcshw(struct cardstate *cs)
>  	ucs->bulk_out_urb =3D NULL;
>  	ucs->read_urb =3D NULL;
>  	tasklet_init(&cs->write_tasklet,
> -		     &gigaset_modem_fill, (unsigned long) cs);
> +		     gigaset_modem_fill, (unsigned long) cs);
> =20
>  	return 1;
>  }
>=20
>=20

--=20
Tilman Schmidt                    E-Mail: tilman@imap.cc
Bonn, Germany
Diese Nachricht besteht zu 100% aus wiederverwerteten Bits.
Unge=C3=B6ffnet mindestens haltbar bis: (siehe R=C3=BCckseite)


--------------enig24EDEBA3D41E64401A2F216B
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.12 (GNU/Linux)
Comment: Using GnuPG with SUSE - http://enigmail.mozdev.org/

iEYEARECAAYFAksILI4ACgkQQ3+did9BuFuxlgCdGr5MJdGMm8EIvn6Vc6YUc+xO
P+gAmQGUZUXTuzQFA7cHRXyi/4Q0yt4z
=klbP
-----END PGP SIGNATURE-----

--------------enig24EDEBA3D41E64401A2F216B--
