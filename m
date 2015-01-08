From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH] net/at91_ether: prepare and unprepare clock
Date: Thu, 8 Jan 2015 11:55:58 +0100
Message-ID: <54AE623E.5020507@atmel.com>
References: <1420671566-30784-1-git-send-email-alexandre.belloni@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Boris Brezillon <boris.brezillon@free-electrons.com>,
	<linux-arm-kernel@lists.infradead.org>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: Alexandre Belloni <alexandre.belloni@free-electrons.com>,
	"David S. Miller" <davem@davemloft.net>,
	Cyrille Pitchen <cyrille.pitchen@atmel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1420671566-30784-1-git-send-email-alexandre.belloni@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 07/01/2015 23:59, Alexandre Belloni a =E9crit :
> The clock is enabled without being prepared, this leads to:
>=20
> WARNING: CPU: 0 PID: 1 at drivers/clk/clk.c:889 __clk_enable+0x24/0xa=
8()
>=20
> and a non working ethernet interface.
>=20
> Use clk_prepare_enable() and clk_disable_unprepare() to handle the cl=
ock.
>=20
> Signed-off-by: Alexandre Belloni <alexandre.belloni@free-electrons.co=
m>

Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>

> ---
>  drivers/net/ethernet/cadence/at91_ether.c | 10 +++++-----
>  1 file changed, 5 insertions(+), 5 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/cadence/at91_ether.c b/drivers/net/=
ethernet/cadence/at91_ether.c
> index 55eb7f2af2b4..7ef55f5fa664 100644
> --- a/drivers/net/ethernet/cadence/at91_ether.c
> +++ b/drivers/net/ethernet/cadence/at91_ether.c
> @@ -340,7 +340,7 @@ static int __init at91ether_probe(struct platform=
_device *pdev)
>  		res =3D PTR_ERR(lp->pclk);
>  		goto err_free_dev;
>  	}
> -	clk_enable(lp->pclk);
> +	clk_prepare_enable(lp->pclk);
> =20
>  	lp->hclk =3D ERR_PTR(-ENOENT);
>  	lp->tx_clk =3D ERR_PTR(-ENOENT);
> @@ -406,7 +406,7 @@ static int __init at91ether_probe(struct platform=
_device *pdev)
>  err_out_unregister_netdev:
>  	unregister_netdev(dev);
>  err_disable_clock:
> -	clk_disable(lp->pclk);
> +	clk_disable_unprepare(lp->pclk);
>  err_free_dev:
>  	free_netdev(dev);
>  	return res;
> @@ -424,7 +424,7 @@ static int at91ether_remove(struct platform_devic=
e *pdev)
>  	kfree(lp->mii_bus->irq);
>  	mdiobus_free(lp->mii_bus);
>  	unregister_netdev(dev);
> -	clk_disable(lp->pclk);
> +	clk_disable_unprepare(lp->pclk);
>  	free_netdev(dev);
> =20
>  	return 0;
> @@ -440,7 +440,7 @@ static int at91ether_suspend(struct platform_devi=
ce *pdev, pm_message_t mesg)
>  		netif_stop_queue(net_dev);
>  		netif_device_detach(net_dev);
> =20
> -		clk_disable(lp->pclk);
> +		clk_disable_unprepare(lp->pclk);
>  	}
>  	return 0;
>  }
> @@ -451,7 +451,7 @@ static int at91ether_resume(struct platform_devic=
e *pdev)
>  	struct macb *lp =3D netdev_priv(net_dev);
> =20
>  	if (netif_running(net_dev)) {
> -		clk_enable(lp->pclk);
> +		clk_prepare_enable(lp->pclk);
> =20
>  		netif_device_attach(net_dev);
>  		netif_start_queue(net_dev);
>=20


--=20
Nicolas Ferre
