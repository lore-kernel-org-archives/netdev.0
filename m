From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH 7/9] net: macb: avoid uninitialized variables
Date: Wed, 27 Jan 2016 16:51:36 +0100
Message-ID: <56A8E788.5020802@atmel.com>
References: <1453903507-3427225-1-git-send-email-arnd@arndb.de>
 <1453903507-3427225-8-git-send-email-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1453903507-3427225-8-git-send-email-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 27/01/2016 15:04, Arnd Bergmann a =E9crit :
> The macb_clk_init function returns three clock pointers, unless
> the it fails to get the first ones. We correctly handle the
> failure case by propagating the error from macb_probe, but
> gcc does not realize this and incorrectly warns about a later
> use of those:
>=20
> In file included from /git/arm-soc/drivers/net/ethernet/cadence/macb.=
c:12:0:
> drivers/net/ethernet/cadence/macb.c: In function 'macb_probe':
> include/linux/clk.h:484:2: error: 'tx_clk' may be used uninitialized =
in this function [-Werror=3Dmaybe-uninitialized]
>   clk_disable(clk);
>   ^
> drivers/net/ethernet/cadence/macb.c:2822:28: note: 'tx_clk' was decla=
red here
>   struct clk *pclk, *hclk, *tx_clk;
>                             ^
> In file included from /git/arm-soc/drivers/net/ethernet/cadence/macb.=
c:12:0:
> include/linux/clk.h:484:2: error: 'hclk' may be used uninitialized in=
 this function [-Werror=3Dmaybe-uninitialized]
>   clk_disable(clk);
>   ^
> drivers/net/ethernet/cadence/macb.c:2822:21: note: 'hclk' was declare=
d here
>   struct clk *pclk, *hclk, *tx_clk;
>                      ^
>=20
> This shuts up the misleading warnings by ensuring that the
> macb_clk_init() always stores something into all three pointers.
>=20
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Okay Arnd, thanks!

Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>

> ---
>  drivers/net/ethernet/cadence/macb.c | 1 +
>  1 file changed, 1 insertion(+)
>=20
> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethern=
et/cadence/macb.c
> index 9d9984a87d42..d3aa74f9db79 100644
> --- a/drivers/net/ethernet/cadence/macb.c
> +++ b/drivers/net/ethernet/cadence/macb.c
> @@ -2268,6 +2268,7 @@ static int macb_clk_init(struct platform_device=
 *pdev, struct clk **pclk,
>  {
>  	int err;
> =20
> +	*tx_clk =3D *hclk =3D NULL;
>  	*pclk =3D devm_clk_get(&pdev->dev, "pclk");
>  	if (IS_ERR(*pclk)) {
>  		err =3D PTR_ERR(*pclk);
>=20


--=20
Nicolas Ferre
