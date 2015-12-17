From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: Re: [PATCH] net/macb: add proper header file
Date: Thu, 17 Dec 2015 13:41:59 +0100
Message-ID: <87twnhs0vc.fsf@free-electrons.com>
References: <1450354553-18745-1-git-send-email-sudipm.mukherjee@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Nicolas Ferre <nicolas.ferre@atmel.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"David S . Miller" <davem@davemloft.net>
To: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1450354553-18745-1-git-send-email-sudipm.mukherjee@gmail.com>
	(Sudip Mukherjee's message of "Thu, 17 Dec 2015 17:45:53 +0530")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Sudip,
=20
 On jeu., d=C3=A9c. 17 2015, Sudip Mukherjee <sudipm.mukherjee@gmail.co=
m> wrote:

> mips allmodconfig build fails with the error:
>
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
>
> Add the proper header file to resolve it. =20


A proper fix already has been posted along with the proper device tree
bindinsg too:
http://marc.info/?l=3Dlinux-netdev&m=3D145034590619620&w=3D2

Thanks,

Gregory

>
> Fixes: 5833e0526820 ("net/macb: add support for resetting PHY using G=
PIO")
> Cc: Gregory CLEMENT <gregory.clement@free-electrons.com>
> Signed-off-by: Sudip Mukherjee <sudip@vectorindia.org>
> ---
>
> build log with next-20151217 is at:
> https://travis-ci.org/sudipm-mukherjee/parport/jobs/97388463
>
>  drivers/net/ethernet/cadence/macb.c | 1 +
>  1 file changed, 1 insertion(+)
>
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
> --=20
> 1.9.1
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--=20
Gregory Clement, Free Electrons
Kernel, drivers, real-time and embedded Linux
development, consulting, training and support.
http://free-electrons.com
