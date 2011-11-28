From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH] net/can: convert drivers/net/can/* to use module_platform_driver()
Date: Mon, 28 Nov 2011 11:17:40 +0100
Message-ID: <4ED35FC4.3040007@pengutronix.de>
References: <1322444551.2408.2.camel@phoenix>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigC283FA6CAFF165F3DDF98FD6"
Cc: linux-kernel@vger.kernel.org,
	Wolfgang Grandegger <wg@grandegger.com>,
	"David S. Miller" <davem@davemloft.net>,
	Bhupesh Sharma <bhupesh.sharma@st.com>,
	Jiri Kosina <jkosina@suse.cz>,
	Grant Likely <grant.likely@secretlab.ca>,
	Anatolij Gustschin <agust@denx.de>,
	Paul Bolle <pebolle@tiscali.nl>,
	Kurt Van Dijck <kurt.van.dijck@eia.be>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	linux-can@vger.kernel.org, netdev@vger.kernel.org
To: Axel Lin <axel.lin@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1322444551.2408.2.camel@phoenix>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigC283FA6CAFF165F3DDF98FD6
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 11/28/2011 02:42 AM, Axel Lin wrote:
> This patch converts the drivers in drivers/net/can/* to use the
> module_platform_driver() macro which makes the code smaller and a bit
> simpler.
>=20
> Cc: Wolfgang Grandegger <wg@grandegger.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Bhupesh Sharma <bhupesh.sharma@st.com>=20
> Cc: Jiri Kosina <jkosina@suse.cz>
> Cc: Grant Likely <grant.likely@secretlab.ca>
> Cc: Anatolij Gustschin <agust@denx.de>=20
> Cc: Paul Bolle <pebolle@tiscali.nl>
> Cc: Kurt Van Dijck <kurt.van.dijck@eia.be>
> Cc: Alexey Dobriyan <adobriyan@gmail.com>=20
> Signed-off-by: Axel Lin <axel.lin@gmail.com>

Acked-by: Marc Kleine-Budde <mkl@pengutronix.de>

> ---
>  drivers/net/can/at91_can.c                    |   13 +------------
>  drivers/net/can/bfin_can.c                    |   12 +-----------
>  drivers/net/can/c_can/c_can_platform.c        |   12 +-----------
>  drivers/net/can/flexcan.c                     |   15 +--------------
>  drivers/net/can/janz-ican3.c                  |   13 +------------
>  drivers/net/can/mscan/mpc5xxx_can.c           |   12 +-----------
>  drivers/net/can/sja1000/sja1000_of_platform.c |   12 +-----------
>  drivers/net/can/sja1000/sja1000_platform.c    |   13 +------------
>  drivers/net/can/softing/softing_main.c        |   16 ++--------------
>  drivers/net/can/ti_hecc.c                     |   15 +--------------
>  10 files changed, 11 insertions(+), 122 deletions(-)
>=20
> diff --git a/drivers/net/can/at91_can.c b/drivers/net/can/at91_can.c
> index 044ea06..6ea905c 100644
> --- a/drivers/net/can/at91_can.c
> +++ b/drivers/net/can/at91_can.c
> @@ -1383,18 +1383,7 @@ static struct platform_driver at91_can_driver =3D=
 {
>  	.id_table =3D at91_can_id_table,
>  };
> =20
> -static int __init at91_can_module_init(void)
> -{
> -	return platform_driver_register(&at91_can_driver);
> -}
> -
> -static void __exit at91_can_module_exit(void)
> -{
> -	platform_driver_unregister(&at91_can_driver);
> -}
> -
> -module_init(at91_can_module_init);
> -module_exit(at91_can_module_exit);
> +module_platform_driver(at91_can_driver);
> =20
>  MODULE_AUTHOR("Marc Kleine-Budde <mkl@pengutronix.de>");
>  MODULE_LICENSE("GPL v2");
> diff --git a/drivers/net/can/bfin_can.c b/drivers/net/can/bfin_can.c
> index a1c5abc..349e0fa 100644
> --- a/drivers/net/can/bfin_can.c
> +++ b/drivers/net/can/bfin_can.c
> @@ -676,17 +676,7 @@ static struct platform_driver bfin_can_driver =3D =
{
>  	},
>  };
> =20
> -static int __init bfin_can_init(void)
> -{
> -	return platform_driver_register(&bfin_can_driver);
> -}
> -module_init(bfin_can_init);
> -
> -static void __exit bfin_can_exit(void)
> -{
> -	platform_driver_unregister(&bfin_can_driver);
> -}
> -module_exit(bfin_can_exit);
> +module_platform_driver(bfin_can_driver);
> =20
>  MODULE_AUTHOR("Barry Song <21cnbao@gmail.com>");
>  MODULE_LICENSE("GPL");
> diff --git a/drivers/net/can/c_can/c_can_platform.c b/drivers/net/can/c=
_can/c_can_platform.c
> index 0b5c6f8..5e1a5ff 100644
> --- a/drivers/net/can/c_can/c_can_platform.c
> +++ b/drivers/net/can/c_can/c_can_platform.c
> @@ -197,17 +197,7 @@ static struct platform_driver c_can_plat_driver =3D=
 {
>  	.remove =3D __devexit_p(c_can_plat_remove),
>  };
> =20
> -static int __init c_can_plat_init(void)
> -{
> -	return platform_driver_register(&c_can_plat_driver);
> -}
> -module_init(c_can_plat_init);
> -
> -static void __exit c_can_plat_exit(void)
> -{
> -	platform_driver_unregister(&c_can_plat_driver);
> -}
> -module_exit(c_can_plat_exit);
> +module_platform_driver(c_can_plat_driver);
> =20
>  MODULE_AUTHOR("Bhupesh Sharma <bhupesh.sharma@st.com>");
>  MODULE_LICENSE("GPL v2");
> diff --git a/drivers/net/can/flexcan.c b/drivers/net/can/flexcan.c
> index e023379..165a4c7 100644
> --- a/drivers/net/can/flexcan.c
> +++ b/drivers/net/can/flexcan.c
> @@ -1060,20 +1060,7 @@ static struct platform_driver flexcan_driver =3D=
 {
>  	.remove =3D __devexit_p(flexcan_remove),
>  };
> =20
> -static int __init flexcan_init(void)
> -{
> -	pr_info("%s netdevice driver\n", DRV_NAME);
> -	return platform_driver_register(&flexcan_driver);
> -}
> -
> -static void __exit flexcan_exit(void)
> -{
> -	platform_driver_unregister(&flexcan_driver);
> -	pr_info("%s: driver removed\n", DRV_NAME);
> -}
> -
> -module_init(flexcan_init);
> -module_exit(flexcan_exit);
> +module_platform_driver(flexcan_driver);
> =20
>  MODULE_AUTHOR("Sascha Hauer <kernel@pengutronix.de>, "
>  	      "Marc Kleine-Budde <kernel@pengutronix.de>");
> diff --git a/drivers/net/can/janz-ican3.c b/drivers/net/can/janz-ican3.=
c
> index 32778d5..08c893c 100644
> --- a/drivers/net/can/janz-ican3.c
> +++ b/drivers/net/can/janz-ican3.c
> @@ -1803,20 +1803,9 @@ static struct platform_driver ican3_driver =3D {=

>  	.remove		=3D __devexit_p(ican3_remove),
>  };
> =20
> -static int __init ican3_init(void)
> -{
> -	return platform_driver_register(&ican3_driver);
> -}
> -
> -static void __exit ican3_exit(void)
> -{
> -	platform_driver_unregister(&ican3_driver);
> -}
> +module_platform_driver(ican3_driver);
> =20
>  MODULE_AUTHOR("Ira W. Snyder <iws@ovro.caltech.edu>");
>  MODULE_DESCRIPTION("Janz MODULbus VMOD-ICAN3 Driver");
>  MODULE_LICENSE("GPL");
>  MODULE_ALIAS("platform:janz-ican3");
> -
> -module_init(ican3_init);
> -module_exit(ican3_exit);
> diff --git a/drivers/net/can/mscan/mpc5xxx_can.c b/drivers/net/can/msca=
n/mpc5xxx_can.c
> index 5fedc33..5caa572 100644
> --- a/drivers/net/can/mscan/mpc5xxx_can.c
> +++ b/drivers/net/can/mscan/mpc5xxx_can.c
> @@ -411,17 +411,7 @@ static struct platform_driver mpc5xxx_can_driver =3D=
 {
>  #endif
>  };
> =20
> -static int __init mpc5xxx_can_init(void)
> -{
> -	return platform_driver_register(&mpc5xxx_can_driver);
> -}
> -module_init(mpc5xxx_can_init);
> -
> -static void __exit mpc5xxx_can_exit(void)
> -{
> -	platform_driver_unregister(&mpc5xxx_can_driver);
> -};
> -module_exit(mpc5xxx_can_exit);
> +module_platform_driver(mpc5xxx_can_driver);
> =20
>  MODULE_AUTHOR("Wolfgang Grandegger <wg@grandegger.com>");
>  MODULE_DESCRIPTION("Freescale MPC5xxx CAN driver");
> diff --git a/drivers/net/can/sja1000/sja1000_of_platform.c b/drivers/ne=
t/can/sja1000/sja1000_of_platform.c
> index c3dd9d0..f2683eb 100644
> --- a/drivers/net/can/sja1000/sja1000_of_platform.c
> +++ b/drivers/net/can/sja1000/sja1000_of_platform.c
> @@ -220,14 +220,4 @@ static struct platform_driver sja1000_ofp_driver =3D=
 {
>  	.remove =3D __devexit_p(sja1000_ofp_remove),
>  };
> =20
> -static int __init sja1000_ofp_init(void)
> -{
> -	return platform_driver_register(&sja1000_ofp_driver);
> -}
> -module_init(sja1000_ofp_init);
> -
> -static void __exit sja1000_ofp_exit(void)
> -{
> -	return platform_driver_unregister(&sja1000_ofp_driver);
> -};
> -module_exit(sja1000_ofp_exit);
> +module_platform_driver(sja1000_ofp_driver);
> diff --git a/drivers/net/can/sja1000/sja1000_platform.c b/drivers/net/c=
an/sja1000/sja1000_platform.c
> index d9fadc4..4f50145 100644
> --- a/drivers/net/can/sja1000/sja1000_platform.c
> +++ b/drivers/net/can/sja1000/sja1000_platform.c
> @@ -185,15 +185,4 @@ static struct platform_driver sp_driver =3D {
>  	},
>  };
> =20
> -static int __init sp_init(void)
> -{
> -	return platform_driver_register(&sp_driver);
> -}
> -
> -static void __exit sp_exit(void)
> -{
> -	platform_driver_unregister(&sp_driver);
> -}
> -
> -module_init(sp_init);
> -module_exit(sp_exit);
> +module_platform_driver(sp_driver);
> diff --git a/drivers/net/can/softing/softing_main.c b/drivers/net/can/s=
ofting/softing_main.c
> index 09a8b86..a7c77c7 100644
> --- a/drivers/net/can/softing/softing_main.c
> +++ b/drivers/net/can/softing/softing_main.c
> @@ -874,21 +874,9 @@ static struct platform_driver softing_driver =3D {=

>  	.remove =3D __devexit_p(softing_pdev_remove),
>  };
> =20
> -MODULE_ALIAS("platform:softing");
> -
> -static int __init softing_start(void)
> -{
> -	return platform_driver_register(&softing_driver);
> -}
> -
> -static void __exit softing_stop(void)
> -{
> -	platform_driver_unregister(&softing_driver);
> -}
> -
> -module_init(softing_start);
> -module_exit(softing_stop);
> +module_platform_driver(softing_driver);
> =20
> +MODULE_ALIAS("platform:softing");
>  MODULE_DESCRIPTION("Softing DPRAM CAN driver");
>  MODULE_AUTHOR("Kurt Van Dijck <kurt.van.dijck@eia.be>");
>  MODULE_LICENSE("GPL v2");
> diff --git a/drivers/net/can/ti_hecc.c b/drivers/net/can/ti_hecc.c
> index 2adc294..df809e3 100644
> --- a/drivers/net/can/ti_hecc.c
> +++ b/drivers/net/can/ti_hecc.c
> @@ -1037,20 +1037,7 @@ static struct platform_driver ti_hecc_driver =3D=
 {
>  	.resume =3D ti_hecc_resume,
>  };
> =20
> -static int __init ti_hecc_init_driver(void)
> -{
> -	printk(KERN_INFO DRV_DESC "\n");
> -	return platform_driver_register(&ti_hecc_driver);
> -}
> -
> -static void __exit ti_hecc_exit_driver(void)
> -{
> -	printk(KERN_INFO DRV_DESC " unloaded\n");
> -	platform_driver_unregister(&ti_hecc_driver);
> -}
> -
> -module_exit(ti_hecc_exit_driver);
> -module_init(ti_hecc_init_driver);
> +module_platform_driver(ti_hecc_driver);
> =20
>  MODULE_AUTHOR("Anant Gole <anantgole@ti.com>");
>  MODULE_LICENSE("GPL v2");


--=20
Pengutronix e.K.                  | Marc Kleine-Budde           |
Industrial Linux Solutions        | Phone: +49-231-2826-924     |
Vertretung West/Dortmund          | Fax:   +49-5121-206917-5555 |
Amtsgericht Hildesheim, HRA 2686  | http://www.pengutronix.de   |


--------------enigC283FA6CAFF165F3DDF98FD6
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEUEARECAAYFAk7TX8cACgkQjTAFq1RaXHOTXgCglFHOARPIcF7/PpBuBdNO+mav
jwsAmL34tN76OgTuHmiGpGSTTEp5qC0=
=pc7Z
-----END PGP SIGNATURE-----

--------------enigC283FA6CAFF165F3DDF98FD6--
