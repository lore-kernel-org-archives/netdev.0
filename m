From: Nicolas Ferre <nicolas.ferre@atmel.com>
Subject: Re: [PATCH] net: macb: Remove CONFIG_PM ifdef because of compilation
 warning
Date: Mon, 26 Jan 2015 12:11:50 +0100
Message-ID: <54C620F6.7010008@atmel.com>
References: <7970145ad4d864eaf31d694d22f2fecbcf6825c9.1422002161.git.michal.simek@xilinx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: Michal Simek <michal.simek@xilinx.com>,
	<linux-kernel@vger.kernel.org>, <monstr@monstr.eu>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <7970145ad4d864eaf31d694d22f2fecbcf6825c9.1422002161.git.michal.simek@xilinx.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 23/01/2015 09:36, Michal Simek a =E9crit :
> Fix compilation warning:
> drivers/net/ethernet/cadence/macb.c:2415:12: warning: 'macb_suspend'
> defined but not used [-Wunused-function]
>  static int macb_suspend(struct device *dev)
> drivers/net/ethernet/cadence/macb.c:2432:12: warning: 'macb_resume'
> defined but not used [-Wunused-function]
>  static int macb_resume(struct device *dev)
>=20
> when CONFIG_PM=3Dy, CONFIG_PM_SLEEP=3Dn are used.
>=20
> Signed-off-by: Michal Simek <michal.simek@xilinx.com>

okay:
Acked-by: Nicolas Ferre <nicolas.ferre@atmel.com>

> ---
>=20
>  drivers/net/ethernet/cadence/macb.c | 6 ++----
>  1 file changed, 2 insertions(+), 4 deletions(-)
>=20
> diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethern=
et/cadence/macb.c
> index 3767271c7667..23ae32f118c2 100644
> --- a/drivers/net/ethernet/cadence/macb.c
> +++ b/drivers/net/ethernet/cadence/macb.c
> @@ -2411,8 +2411,7 @@ static int __exit macb_remove(struct platform_d=
evice *pdev)
>  	return 0;
>  }
>=20
> -#ifdef CONFIG_PM
> -static int macb_suspend(struct device *dev)
> +static int __maybe_unused macb_suspend(struct device *dev)
>  {
>  	struct platform_device *pdev =3D to_platform_device(dev);
>  	struct net_device *netdev =3D platform_get_drvdata(pdev);
> @@ -2429,7 +2428,7 @@ static int macb_suspend(struct device *dev)
>  	return 0;
>  }
>=20
> -static int macb_resume(struct device *dev)
> +static int __maybe_unused macb_resume(struct device *dev)
>  {
>  	struct platform_device *pdev =3D to_platform_device(dev);
>  	struct net_device *netdev =3D platform_get_drvdata(pdev);
> @@ -2444,7 +2443,6 @@ static int macb_resume(struct device *dev)
>=20
>  	return 0;
>  }
> -#endif
>=20
>  static SIMPLE_DEV_PM_OPS(macb_pm_ops, macb_suspend, macb_resume);
>=20
> --
> 1.8.2.3
>=20


--=20
Nicolas Ferre
