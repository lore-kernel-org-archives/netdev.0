From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v4 2/8] net: can: c_can: Introduce c_can_driver_data structure
Date: Thu, 13 Nov 2014 11:57:50 +0100
Message-ID: <54648EAE.8050701@pengutronix.de>
References: <1415371762-29885-1-git-send-email-rogerq@ti.com> <1415371762-29885-3-git-send-email-rogerq@ti.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="OkNEfPOCsVjV1bMPB0I6dIU6na1D8teoE"
Cc: wsa@the-dreams.de, tony@atomide.com, tglx@linutronix.de,
	mugunthanvnm@ti.com, george.cherian@ti.com, balbi@ti.com,
	nsekhar@ti.com, nm@ti.com, sergei.shtylyov@cogentembedded.com,
	linux-omap@vger.kernel.org, linux-can@vger.kernel.org,
	netdev@vger.kernel.org
To: Roger Quadros <rogerq@ti.com>, wg@grandegger.com
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1415371762-29885-3-git-send-email-rogerq@ti.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--OkNEfPOCsVjV1bMPB0I6dIU6na1D8teoE
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 11/07/2014 03:49 PM, Roger Quadros wrote:
> We want to have more data than just can_dev_id to be present
> in the driver data e.g. TI platforms need RAMINIT register
> description. Introduce the c_can_driver_data structure and move
> the can_dev_id into it.
>=20
> Tidy up the way it is used on probe().
>=20
> Signed-off-by: Roger Quadros <rogerq@ti.com>

[...]

> @@ -198,21 +206,19 @@ static int c_can_plat_probe(struct platform_devic=
e *pdev)
>  	struct net_device *dev;
>  	struct c_can_priv *priv;
>  	const struct of_device_id *match;
> -	const struct platform_device_id *id;
>  	struct resource *mem, *res;
>  	int irq;
>  	struct clk *clk;
> -
> -	if (pdev->dev.of_node) {
> -		match =3D of_match_device(c_can_of_table, &pdev->dev);
> -		if (!match) {
> -			dev_err(&pdev->dev, "Failed to find matching dt id\n");
> -			ret =3D -EINVAL;
> -			goto exit;
> -		}
> -		id =3D match->data;
> +	const struct c_can_driver_data *drvdata;
> +
> +	match =3D of_match_device(c_can_of_table, &pdev->dev);
> +	if (match) {
> +		drvdata =3D match->data;
> +	} else if (pdev->id_entry->driver_data) {
> +		drvdata =3D (struct c_can_driver_data *)
> +			   pdev->id_entry->driver_data;
                           ^^^^^^^^^^^^^^
I've changes this to platform_get_device_id() while aplying.

Marc

--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--OkNEfPOCsVjV1bMPB0I6dIU6na1D8teoE
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUZI6uAAoJECte4hHFiupUWqAQAKBVwHBv1QSDkkIvNFpKefxa
qYiCvqn5TUgRiQHE65w6xScX8eUiDful9brI4pHqsRLBNPn50VkNnSkIZXugRK29
GNCSPSCXT2zY0Ymmlc9RGgZ0GBBO90bLkzxZ21qxElJL1dm6geEtbiheH5uJ6Rsm
1tB3Gy2AELh9k6Gy/WKRsGdj6c3bxtyr9b08ELzwCu1PJ4+XJzBjTisAcTYhSaKv
pg/fpYxy2acwl+ZssWBJCjoo8IV1gFtx8H39W+hkzvKi2i6ZBobXkg+MlcnZczdN
9vhDWYG25XNRUasf+Hoo3eR8DWIwZdUzkqd4djY9YtGRQYhAhf5iJkoFl5jWWALJ
X8MJmC9tj0H513bZHCWrxRy408OutUOgb/x6DNBv99z3rZLoWacIa/AHkktSpGXa
FY/zPn+iPUpbFe8eT+kdy2wH8+0r1RAH3gGudyjPd71xfatdVqBKZgmMe+bwe26S
Feqk3YFn68pJC0TQi/ayIR37pOROulrkIwL1ACJHjmS6h/uC0pt/OzOYu9S2fyXq
14ECfU+JsnL9t/NqsNCPkxl6QN5s1LV6IJCFXuyoVC6sf1nQME+/KJvtuzcbvu/B
yGsyaWVwgdf1AK3A0Om/bmgB8HKb4lW6jwwQHKgkYs+r9Q0LZIGUe5+xaZRCFSWC
hOGSCa5RnVssQUhQ0/R6
=KKaZ
-----END PGP SIGNATURE-----

--OkNEfPOCsVjV1bMPB0I6dIU6na1D8teoE--
