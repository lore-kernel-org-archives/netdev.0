From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH 4/7] can/at91: don't check platform_get_irq's return value
 against zero
Date: Wed, 16 Dec 2009 19:58:38 +0100
Message-ID: <4B292DDE.6080906@grandegger.com>
References: <1260979809-24811-1-git-send-email-u.kleine-koenig@pengutronix.de> <1260979809-24811-2-git-send-email-u.kleine-koenig@pengutronix.de> <1260979809-24811-3-git-send-email-u.kleine-koenig@pengutronix.de> <1260979809-24811-4-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, David Vrabel <dvrabel@arcom.com>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Urs Thuermann <urs.thuermann@volkswagen.de>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	"David S. Miller" <davem@davemloft.net>,
	Kurt Van Dijck <kurt.van.dijck@eia.be>,
	netdev@vger.kernel.org
To: =?ISO-8859-1?Q?Uwe_Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S933748AbZLPS7q@vger.kernel.org>
In-Reply-To: <1260979809-24811-4-git-send-email-u.kleine-koenig@pengutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Uwe Kleine-K=F6nig wrote:
> platform_get_irq returns -ENXIO on failure, so !irq was probably
> always true.  Better use (int)irq <=3D 0.  Note that a return value o=
f
> zero is still handled as error even though this could mean irq0.
>=20
> This is a followup to 305b3228f9ff4d59f49e6d34a7034d44ee8ce2f0 that
> changed the return value of platform_get_irq from 0 to -ENXIO on erro=
r.
>=20
> Signed-off-by: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>
> Cc: David Vrabel <dvrabel@arcom.com>
> Cc: Greg Kroah-Hartman <gregkh@suse.de>
> Cc: Urs Thuermann <urs.thuermann@volkswagen.de>
> Cc: Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Wolfgang Grandegger <wg@grandegger.com>
> Cc: Kurt Van Dijck <kurt.van.dijck@eia.be>
> Cc: netdev@vger.kernel.org

Signed-off-by: Wolfgang Grandegger <wg@grandegger.com>

> ---
>  drivers/net/can/at91_can.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
>=20
> diff --git a/drivers/net/can/at91_can.c b/drivers/net/can/at91_can.c
> index cbe3fce..631d404 100644
> --- a/drivers/net/can/at91_can.c
> +++ b/drivers/net/can/at91_can.c
> @@ -1037,7 +1037,7 @@ static int __init at91_can_probe(struct platfor=
m_device *pdev)
> =20
>  	res =3D platform_get_resource(pdev, IORESOURCE_MEM, 0);
>  	irq =3D platform_get_irq(pdev, 0);
> -	if (!res || !irq) {
> +	if (!res || irq <=3D 0) {
>  		err =3D -ENODEV;
>  		goto exit_put;
>  	}

Thanks,

Wolfgang.
