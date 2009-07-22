From: David Brownell <david-b@pacbell.net>
Subject: Re: [PATCH] register at91_ether using platform_driver_probe
Date: Wed, 22 Jul 2009 10:37:36 -0700
Message-ID: <200907221037.36541.david-b@pacbell.net>
References: <200907111527.46441.david-b@pacbell.net> <1248207099-14583-1-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	David Brownell <dbrownell@users.sourceforge.net>,
	netdev@vger.kernel.org,
	Paulius Zaleckas <paulius.zaleckas@teltonika.lt>,
	Marc Pignat <marc.pignat@hevs.ch>,
	Andrew Victor <linux@maxim.org.za>,
	Roel Kluin <12o3l@tiscali.nl>,
	Andrew Morton <akpm@linux-foundation.org>,
	"Greg Kroah-Hartman" <gregkh@suse.de>
To: "Uwe =?iso-8859-1?q?Kleine-K=F6nig?="
	<u.kleine-koenig@pengutronix.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754066AbZGVRhi@vger.kernel.org>
In-Reply-To: <1248207099-14583-1-git-send-email-u.kleine-koenig@pengutronix.de>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 21 July 2009, Uwe Kleine-K=F6nig wrote:
> at91ether_probe lives in .init.text, so using platform_driver_registe=
r
> to register it is wrong because binding a device after the init memor=
y
> is discarded (e.g. via sysfs) results in an oops.
>=20
> As requested by David Brownell platform_driver_probe is used instead =
of
> moving the probe function to .devinit.text as proposed initially.
> This saves some memory, but devices registered after the driver is
> probed are not bound (probably there are none) and binding via sysfs
> isn't possible.

Right, these devices do not hotplug.

>=20
> Signed-off-by: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>
> Cc: David Brownell <dbrownell@users.sourceforge.net>

Acked-by: David Brownell <dbrownell@users.sourceforge.net>

=2E... and thanks for doing it this way.  :)

> Cc: netdev@vger.kernel.org
> Cc: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
> Cc: Marc Pignat <marc.pignat@hevs.ch>
> Cc: Andrew Victor <linux@maxim.org.za>
> Cc: Roel Kluin <12o3l@tiscali.nl>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Greg Kroah-Hartman <gregkh@suse.de>
>=20
> ---
>  drivers/net/arm/at91_ether.c |    3 +--
>  1 files changed, 1 insertions(+), 2 deletions(-)
>=20
> diff --git a/drivers/net/arm/at91_ether.c b/drivers/net/arm/at91_ethe=
r.c
> index 2e7419a..5041d10 100644
> --- a/drivers/net/arm/at91_ether.c
> +++ b/drivers/net/arm/at91_ether.c
> @@ -1228,7 +1228,6 @@ static int at91ether_resume(struct platform_dev=
ice *pdev)
>  #endif
> =20
>  static struct platform_driver at91ether_driver =3D {
> -	.probe		=3D at91ether_probe,
>  	.remove		=3D __devexit_p(at91ether_remove),
>  	.suspend	=3D at91ether_suspend,
>  	.resume		=3D at91ether_resume,
> @@ -1240,7 +1239,7 @@ static struct platform_driver at91ether_driver =
=3D {
> =20
>  static int __init at91ether_init(void)
>  {
> -	return platform_driver_register(&at91ether_driver);
> +	return platform_driver_probe(&at91ether_driver, at91ether_probe);
>  }
> =20
>  static void __exit at91ether_exit(void)
> --=20
> tg: (4b0a840..) t/platsection/at91ether_driver (depends on: linus/mas=
ter)
>=20
>=20
