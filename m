From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH] of_mdio: Remove flags argument from of_phy_connect
Date: Fri, 29 Mar 2013 18:45:14 +0100
Message-ID: <5155D32A.3030603@openwrt.org>
References: <E1UJ1fR-0004hv-8a@swissweb.swissdisk.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	Grant Likely <grant.likely@secretlab.ca>,
	Rob Herring <rob.herring@calxeda.com>,
	devicetree-discuss@lists.ozlabs.org,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ben Collins <ben.c@servergy.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <E1UJ1fR-0004hv-8a@swissweb.swissdisk.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 03/19/13 00:49, Ben Collins a =C3=A9crit :
> of_phy_connect() only required a flags argument in order to pass it d=
own to
> to phy_connect(). Since that argument was removed, it is of no use in=
 this
> function either (confirmed by checking all callers in kernel tree as =
well).

Looks good to me:

Reviewed-by: Florian Fainelli <florian@openwrt.org>

(you should have CC'd netdev@vger.kernel.org as it is probably going to=
=20
get merged via the net tree)

>
> Signed-off-by: Ben Collins <ben.c@servergy.com>
> Cc: Grant Likely <grant.likely@secretlab.ca>
> Cc: Rob Herring <rob.herring@calxeda.com>
> Cc: devicetree-discuss@lists.ozlabs.org
> ---
>   drivers/net/ethernet/freescale/fec_mpc52xx.c          | 2 +-
>   drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c | 2 +-
>   drivers/net/ethernet/freescale/gianfar.c              | 2 +-
>   drivers/net/ethernet/freescale/ucc_geth.c             | 2 +-
>   drivers/net/ethernet/marvell/mvneta.c                 | 2 +-
>   drivers/net/ethernet/octeon/octeon_mgmt.c             | 2 +-
>   drivers/net/ethernet/pasemi/pasemi_mac.c              | 2 +-
>   drivers/net/ethernet/xilinx/ll_temac_main.c           | 2 +-
>   drivers/net/ethernet/xilinx/xilinx_axienet_main.c     | 2 +-
>   drivers/net/ethernet/xilinx/xilinx_emaclite.c         | 2 +-
>   drivers/of/of_mdio.c                                  | 2 +-
>   drivers/staging/octeon/ethernet-mdio.c                | 2 +-
>   include/linux/of_mdio.h                               | 4 ++--
>   13 files changed, 14 insertions(+), 14 deletions(-)
>
> diff --git a/drivers/net/ethernet/freescale/fec_mpc52xx.c b/drivers/n=
et/ethernet/freescale/fec_mpc52xx.c
> index 77943a6..ea01dcd 100644
> --- a/drivers/net/ethernet/freescale/fec_mpc52xx.c
> +++ b/drivers/net/ethernet/freescale/fec_mpc52xx.c
> @@ -217,7 +217,7 @@ static int mpc52xx_fec_open(struct net_device *de=
v)
>
>   	if (priv->phy_node) {
>   		priv->phydev =3D of_phy_connect(priv->ndev, priv->phy_node,
> -					      mpc52xx_fec_adjust_link, 0, 0);
> +					      mpc52xx_fec_adjust_link, 0);
>   		if (!priv->phydev) {
>   			dev_err(&dev->dev, "of_phy_connect failed\n");
>   			return -ENODEV;
> diff --git a/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c b/=
drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
> index 46df288..5523fc0 100644
> --- a/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
> +++ b/drivers/net/ethernet/freescale/fs_enet/fs_enet-main.c
> @@ -799,7 +799,7 @@ static int fs_init_phy(struct net_device *dev)
>   	iface =3D fep->fpi->use_rmii ?
>   		PHY_INTERFACE_MODE_RMII : PHY_INTERFACE_MODE_MII;
>
> -	phydev =3D of_phy_connect(dev, fep->fpi->phy_node, &fs_adjust_link,=
 0,
> +	phydev =3D of_phy_connect(dev, fep->fpi->phy_node, &fs_adjust_link,
>   				iface);
>   	if (!phydev) {
>   		phydev =3D of_phy_connect_fixed_link(dev, &fs_adjust_link,
> diff --git a/drivers/net/ethernet/freescale/gianfar.c b/drivers/net/e=
thernet/freescale/gianfar.c
> index d2c5441..383d302 100644
> --- a/drivers/net/ethernet/freescale/gianfar.c
> +++ b/drivers/net/ethernet/freescale/gianfar.c
> @@ -1467,7 +1467,7 @@ static int init_phy(struct net_device *dev)
>
>   	interface =3D gfar_get_interface(dev);
>
> -	priv->phydev =3D of_phy_connect(dev, priv->phy_node, &adjust_link, =
0,
> +	priv->phydev =3D of_phy_connect(dev, priv->phy_node, &adjust_link,
>   				      interface);
>   	if (!priv->phydev)
>   		priv->phydev =3D of_phy_connect_fixed_link(dev, &adjust_link,
> diff --git a/drivers/net/ethernet/freescale/ucc_geth.c b/drivers/net/=
ethernet/freescale/ucc_geth.c
> index 0a70bb5..fb9a573 100644
> --- a/drivers/net/ethernet/freescale/ucc_geth.c
> +++ b/drivers/net/ethernet/freescale/ucc_geth.c
> @@ -1745,7 +1745,7 @@ static int init_phy(struct net_device *dev)
>   	priv->oldspeed =3D 0;
>   	priv->oldduplex =3D -1;
>
> -	phydev =3D of_phy_connect(dev, ug_info->phy_node, &adjust_link, 0,
> +	phydev =3D of_phy_connect(dev, ug_info->phy_node, &adjust_link,
>   				priv->phy_interface);
>   	if (!phydev)
>   		phydev =3D of_phy_connect_fixed_link(dev, &adjust_link,
> diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethe=
rnet/marvell/mvneta.c
> index cd345b8..dcb865e8 100644
> --- a/drivers/net/ethernet/marvell/mvneta.c
> +++ b/drivers/net/ethernet/marvell/mvneta.c
> @@ -2344,7 +2344,7 @@ static int mvneta_mdio_probe(struct mvneta_port=
 *pp)
>   {
>   	struct phy_device *phy_dev;
>
> -	phy_dev =3D of_phy_connect(pp->dev, pp->phy_node, mvneta_adjust_lin=
k, 0,
> +	phy_dev =3D of_phy_connect(pp->dev, pp->phy_node, mvneta_adjust_lin=
k,
>   				 pp->phy_interface);
>   	if (!phy_dev) {
>   		netdev_err(pp->dev, "could not find the PHY\n");
> diff --git a/drivers/net/ethernet/octeon/octeon_mgmt.c b/drivers/net/=
ethernet/octeon/octeon_mgmt.c
> index 921729f..c2d281e 100644
> --- a/drivers/net/ethernet/octeon/octeon_mgmt.c
> +++ b/drivers/net/ethernet/octeon/octeon_mgmt.c
> @@ -970,7 +970,7 @@ static int octeon_mgmt_init_phy(struct net_device=
 *netdev)
>   	}
>
>   	p->phydev =3D of_phy_connect(netdev, p->phy_np,
> -				   octeon_mgmt_adjust_link, 0,
> +				   octeon_mgmt_adjust_link,
>   				   PHY_INTERFACE_MODE_MII);
>
>   	if (!p->phydev)
> diff --git a/drivers/net/ethernet/pasemi/pasemi_mac.c b/drivers/net/e=
thernet/pasemi/pasemi_mac.c
> index b1cfbb7..aad29d1 100644
> --- a/drivers/net/ethernet/pasemi/pasemi_mac.c
> +++ b/drivers/net/ethernet/pasemi/pasemi_mac.c
> @@ -1100,7 +1100,7 @@ static int pasemi_mac_phy_init(struct net_devic=
e *dev)
>   	mac->speed =3D 0;
>   	mac->duplex =3D -1;
>
> -	phydev =3D of_phy_connect(dev, phy_dn, &pasemi_adjust_link, 0,
> +	phydev =3D of_phy_connect(dev, phy_dn, &pasemi_adjust_link,
>   				PHY_INTERFACE_MODE_SGMII);
>
>   	if (!phydev) {
> diff --git a/drivers/net/ethernet/xilinx/ll_temac_main.c b/drivers/ne=
t/ethernet/xilinx/ll_temac_main.c
> index 9fc2ada..4c5e0a9 100644
> --- a/drivers/net/ethernet/xilinx/ll_temac_main.c
> +++ b/drivers/net/ethernet/xilinx/ll_temac_main.c
> @@ -857,7 +857,7 @@ static int temac_open(struct net_device *ndev)
>
>   	if (lp->phy_node) {
>   		lp->phy_dev =3D of_phy_connect(lp->ndev, lp->phy_node,
> -					     temac_adjust_link, 0, 0);
> +					     temac_adjust_link, 0);
>   		if (!lp->phy_dev) {
>   			dev_err(lp->dev, "of_phy_connect() failed\n");
>   			return -ENODEV;
> diff --git a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c b/driv=
ers/net/ethernet/xilinx/xilinx_axienet_main.c
> index 278c9db..7f2afdd 100644
> --- a/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
> +++ b/drivers/net/ethernet/xilinx/xilinx_axienet_main.c
> @@ -935,7 +935,7 @@ static int axienet_open(struct net_device *ndev)
>
>   	if (lp->phy_node) {
>   		lp->phy_dev =3D of_phy_connect(lp->ndev, lp->phy_node,
> -					     axienet_adjust_link, 0,
> +					     axienet_adjust_link,
>   					     PHY_INTERFACE_MODE_GMII);
>   		if (!lp->phy_dev) {
>   			dev_err(lp->dev, "of_phy_connect() failed\n");
> diff --git a/drivers/net/ethernet/xilinx/xilinx_emaclite.c b/drivers/=
net/ethernet/xilinx/xilinx_emaclite.c
> index 919b983..bccb064 100644
> --- a/drivers/net/ethernet/xilinx/xilinx_emaclite.c
> +++ b/drivers/net/ethernet/xilinx/xilinx_emaclite.c
> @@ -931,7 +931,7 @@ static int xemaclite_open(struct net_device *dev)
>   		u32 bmcr;
>
>   		lp->phy_dev =3D of_phy_connect(lp->ndev, lp->phy_node,
> -					     xemaclite_adjust_link, 0,
> +					     xemaclite_adjust_link,
>   					     PHY_INTERFACE_MODE_MII);
>   		if (!lp->phy_dev) {
>   			dev_err(&lp->ndev->dev, "of_phy_connect() failed\n");
> diff --git a/drivers/of/of_mdio.c b/drivers/of/of_mdio.c
> index e3a8b22..199b7f2 100644
> --- a/drivers/of/of_mdio.c
> +++ b/drivers/of/of_mdio.c
> @@ -149,7 +149,7 @@ EXPORT_SYMBOL(of_phy_find_device);
>    */
>   struct phy_device *of_phy_connect(struct net_device *dev,
>   				  struct device_node *phy_np,
> -				  void (*hndlr)(struct net_device *), u32 flags,
> +				  void (*hndlr)(struct net_device *),
>   				  phy_interface_t iface)
>   {
>   	struct phy_device *phy =3D of_phy_find_device(phy_np);
> diff --git a/drivers/staging/octeon/ethernet-mdio.c b/drivers/staging=
/octeon/ethernet-mdio.c
> index 83b1030..37897e3 100644
> --- a/drivers/staging/octeon/ethernet-mdio.c
> +++ b/drivers/staging/octeon/ethernet-mdio.c
> @@ -171,7 +171,7 @@ int cvm_oct_phy_setup_device(struct net_device *d=
ev)
>   	if (!phy_node)
>   		return 0;
>
> -	priv->phydev =3D of_phy_connect(dev, phy_node, cvm_oct_adjust_link,=
 0,
> +	priv->phydev =3D of_phy_connect(dev, phy_node, cvm_oct_adjust_link,
>   				      PHY_INTERFACE_MODE_GMII);
>
>   	if (priv->phydev =3D=3D NULL)
> diff --git a/include/linux/of_mdio.h b/include/linux/of_mdio.h
> index 8163107..cdc62c9 100644
> --- a/include/linux/of_mdio.h
> +++ b/include/linux/of_mdio.h
> @@ -18,7 +18,7 @@ extern struct phy_device *of_phy_find_device(struct=
 device_node *phy_np);
>   extern struct phy_device *of_phy_connect(struct net_device *dev,
>   					 struct device_node *phy_np,
>   					 void (*hndlr)(struct net_device *),
> -					 u32 flags, phy_interface_t iface);
> +					 phy_interface_t iface);
>   extern struct phy_device *of_phy_connect_fixed_link(struct net_devi=
ce *dev,
>   					 void (*hndlr)(struct net_device *),
>   					 phy_interface_t iface);
> @@ -39,7 +39,7 @@ static inline struct phy_device *of_phy_find_device=
(struct device_node *phy_np)
>   static inline struct phy_device *of_phy_connect(struct net_device *=
dev,
>   						struct device_node *phy_np,
>   						void (*hndlr)(struct net_device *),
> -						u32 flags, phy_interface_t iface)
> +						phy_interface_t iface)
>   {
>   	return NULL;
>   }
>
