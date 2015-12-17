From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH] net/macb: add proper header file
Date: Thu, 17 Dec 2015 13:47:00 +0100
Message-ID: <5672AEC4.70800@atmel.com>
References: <1450354553-18745-1-git-send-email-sudipm.mukherjee@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: Sudip Mukherjee <sudipm.mukherjee@gmail.com>,
	"David S . Miller" <davem@davemloft.net>,
	Gregory CLEMENT <gregory.clement@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1450354553-18745-1-git-send-email-sudipm.mukherjee@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 17/12/2015 13:15, Sudip Mukherjee a =E9crit :
> mips allmodconfig build fails with the error:
>=20
> drivers/net/ethernet/cadence/macb.c: In function 'macb_probe':
> drivers/net/ethernet/cadence/macb.c:2908:2: error: implicit declarati=
on of function 'devm_gpiod_get_optional' [-Werror=3Dimplicit-function-d=
eclaration]
>   bp->reset_gpio =3D devm_gpiod_get_optional(&bp->pdev->dev, "phy-res=
et",
>   ^
> drivers/net/ethernet/cadence/macb.c:2909:8: error: 'GPIOD_OUT_HIGH' u=
ndeclared (first use in this function)
>         GPIOD_OUT_HIGH);
>         ^
> drivers/net/ethernet/cadence/macb.c:2909:8: note: each undeclared ide=
ntifier is reported only once for each function it appears in
> drivers/net/ethernet/cadence/macb.c: In function 'macb_remove':
> drivers/net/ethernet/cadence/macb.c:2979:3: error: implicit declarati=
on of function 'gpiod_set_value' [-Werror=3Dimplicit-function-declarati=
on]
>    gpiod_set_value(bp->reset_gpio, 0);
>    ^
>=20
> Add the proper header file to resolve it. =20
>=20
> Fixes: 5833e0526820 ("net/macb: add support for resetting PHY using G=
PIO")
> Cc: Gregory CLEMENT <gregory.clement@free-electrons.com>
> Signed-off-by: Sudip Mukherjee <sudip@vectorindia.org>

This one is fixed and handled by Gregory here:
http://lists.infradead.org/pipermail/linux-arm-kernel/2015-December/394=
433.html

Thanks a lot anyay, bye,


> ---
>=20
> build log with next-20151217 is at:
> https://travis-ci.org/sudipm-mukherjee/parport/jobs/97388463
>=20
>  drivers/net/ethernet/cadence/macb.c | 1 +
>  1 file changed, 1 insertion(+)
>=20
> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethern=
et/cadence/macb.c
> index 0123646..988ee14 100644
> --- a/drivers/net/ethernet/cadence/macb.c
> +++ b/drivers/net/ethernet/cadence/macb.c
> @@ -19,6 +19,7 @@
>  #include <linux/init.h>
>  #include <linux/io.h>
>  #include <linux/gpio.h>
> +#include <linux/gpio/consumer.h>
>  #include <linux/interrupt.h>
>  #include <linux/netdevice.h>
>  #include <linux/etherdevice.h>
>=20


--=20
Nicolas Ferre
