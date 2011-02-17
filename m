From: Nobuhiro Iwamatsu <iwamatsu@nigauri.org>
Subject: Re: [RFC, PATCH 2/4] net: sh_eth: remove the SH_TSU_ADDR
Date: Thu, 17 Feb 2011 09:24:39 +0900
Message-ID: <AANLkTimJM0yEOU6RgoAs+Njv5b7ixVRnPubnUg=F72GX@mail.gmail.com>
References: <4D5A67CF.3040406@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, SH-Linux <linux-sh@vger.kernel.org>
To: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <4D5A67CF.3040406@renesas.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2011/2/15 Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>:
> The defination is hardcoded in this driver for some CPUs. This patch
> modifies to get resource of TSU address from platform_device.
>
> Signed-off-by: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
> ---
> =A0drivers/net/sh_eth.c | =A0 16 ++++++++++++----
> =A0drivers/net/sh_eth.h | =A0 15 ---------------
> =A02 files changed, 12 insertions(+), 19 deletions(-)
>
> diff --git a/drivers/net/sh_eth.c b/drivers/net/sh_eth.c
> index 3b6d545..0593f29 100644
> --- a/drivers/net/sh_eth.c
> +++ b/drivers/net/sh_eth.c
> @@ -1446,7 +1446,7 @@ static const struct net_device_ops sh_eth_netde=
v_ops =3D {
> =A0static int sh_eth_drv_probe(struct platform_device *pdev)
> =A0{
> =A0 =A0 =A0 =A0int ret, devno =3D 0;
> - =A0 =A0 =A0 struct resource *res;
> + =A0 =A0 =A0 struct resource *res, *res_tsu;
> =A0 =A0 =A0 =A0struct net_device *ndev =3D NULL;
> =A0 =A0 =A0 =A0struct sh_eth_private *mdp;
> =A0 =A0 =A0 =A0struct sh_eth_plat_data *pd;
> @@ -1520,9 +1520,13 @@ static int sh_eth_drv_probe(struct platform_de=
vice *pdev)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mdp->cd->chip_reset(nd=
ev);
>
> =A0#if defined(SH_ETH_HAS_TSU)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* TSU init (Init only)*/
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 mdp->tsu_addr =3D SH_TSU_ADDR;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 sh_eth_tsu_init(mdp);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 res_tsu =3D platform_get_resource(pdev,=
 IORESOURCE_MEM, 1);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (res_tsu) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mdp->tsu_addr =3D iorem=
ap(res_tsu->start,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 resource_size(res_tsu));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* TSU init (Init only)=
*/
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sh_eth_tsu_init(mdp);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> =A0#endif
> =A0 =A0 =A0 =A0}
>
> @@ -1549,6 +1553,8 @@ out_unregister:
>
> =A0out_release:
> =A0 =A0 =A0 =A0/* net_dev free */
> + =A0 =A0 =A0 if (mdp->tsu_addr)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 iounmap(mdp->tsu_addr);
> =A0 =A0 =A0 =A0if (ndev)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0free_netdev(ndev);
>
> @@ -1559,7 +1565,9 @@ out:
> =A0static int sh_eth_drv_remove(struct platform_device *pdev)
> =A0{
> =A0 =A0 =A0 =A0struct net_device *ndev =3D platform_get_drvdata(pdev)=
;
> + =A0 =A0 =A0 struct sh_eth_private *mdp =3D netdev_priv(ndev);
>
> + =A0 =A0 =A0 iounmap(mdp->tsu_addr);
> =A0 =A0 =A0 =A0sh_mdio_release(ndev);
> =A0 =A0 =A0 =A0unregister_netdev(ndev);
> =A0 =A0 =A0 =A0pm_runtime_disable(&pdev->dev);

You forget to fix for ARSTR.

Best regards,
  Nobuhiro
--=20
Nobuhiro Iwamatsu
=A0=A0 iwamatsu at {nigauri.org / debian.org}
=A0=A0 GPG ID: 40AD1FA6
