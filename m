From: Fugang Duan <fugang.duan@nxp.com>
Subject: RE: [PATCH 3/3] fec: move to new ethtool api {get|set}_link_ksettings
Date: Fri, 15 Apr 2016 02:38:11 +0000
Message-ID: <VI1PR0401MB18550805A0305855FB105E36FF680@VI1PR0401MB1855.eurprd04.prod.outlook.com>
References: <1460673301-10599-1-git-send-email-tremyfr@gmail.com>
 <1460673301-10599-4-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Philippe Reynes <tremyfr@gmail.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"decot@googlers.com" <decot@googlers.com>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-am1on0099.outbound.protection.outlook.com ([157.56.112.99]:16608
	"EHLO emea01-am1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751248AbcDOCiP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Apr 2016 22:38:15 -0400
In-Reply-To: <1460673301-10599-4-git-send-email-tremyfr@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Philippe Reynes <tremyfr@gmail.com> Sent: Friday, April 15, 2016 6:35 AM
> To: davem@davemloft.net; decot@googlers.com; f.fainelli@gmail.com; Fugang
> Duan <fugang.duan@nxp.com>
> Cc: linux-kernel@vger.kernel.org; netdev@vger.kernel.org; Philippe Reynes
> <tremyfr@gmail.com>
> Subject: [PATCH 3/3] fec: move to new ethtool api {get|set}_link_ksettings
> 
> The ethtool api {get|set}_settings is deprecated.
> We move the fec driver to new api {get|set}_link_ksettings.
> 
> Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
> ---
>  drivers/net/ethernet/freescale/fec_main.c |   16 ++++++++--------
>  1 files changed, 8 insertions(+), 8 deletions(-)
> 
> diff --git a/drivers/net/ethernet/freescale/fec_main.c
> b/drivers/net/ethernet/freescale/fec_main.c
> index 08243c2..bfa10c3 100644
> --- a/drivers/net/ethernet/freescale/fec_main.c
> +++ b/drivers/net/ethernet/freescale/fec_main.c
> @@ -2058,8 +2058,8 @@ static void fec_enet_mii_remove(struct
> fec_enet_private *fep)
>  	}
>  }
> 
> -static int fec_enet_get_settings(struct net_device *ndev,
> -				  struct ethtool_cmd *cmd)
> +static int fec_enet_get_link_ksettings(struct net_device *ndev,
> +				       struct ethtool_link_ksettings *cmd)
>  {
>  	struct fec_enet_private *fep = netdev_priv(ndev);
>  	struct phy_device *phydev = fep->phy_dev; @@ -2067,11 +2067,11
> @@ static int fec_enet_get_settings(struct net_device *ndev,
>  	if (!phydev)
>  		return -ENODEV;
> 
> -	return phy_ethtool_gset(phydev, cmd);
> +	return phy_ethtool_ksettings_get(phydev, cmd);
>  }
> 
> -static int fec_enet_set_settings(struct net_device *ndev,
> -				 struct ethtool_cmd *cmd)
> +static int fec_enet_set_link_ksettings(struct net_device *ndev,
> +				       const struct ethtool_link_ksettings *cmd)
>  {
>  	struct fec_enet_private *fep = netdev_priv(ndev);
>  	struct phy_device *phydev = fep->phy_dev; @@ -2079,7 +2079,7 @@
> static int fec_enet_set_settings(struct net_device *ndev,
>  	if (!phydev)
>  		return -ENODEV;
> 
> -	return phy_ethtool_sset(phydev, cmd);
> +	return phy_ethtool_ksettings_set(phydev, cmd);
>  }
> 
>  static void fec_enet_get_drvinfo(struct net_device *ndev, @@ -2562,8
> +2562,6 @@ fec_enet_set_wol(struct net_device *ndev, struct
> ethtool_wolinfo *wol)  }
> 
>  static const struct ethtool_ops fec_enet_ethtool_ops = {
> -	.get_settings		= fec_enet_get_settings,
> -	.set_settings		= fec_enet_set_settings,
>  	.get_drvinfo		= fec_enet_get_drvinfo,
>  	.get_regs_len		= fec_enet_get_regs_len,
>  	.get_regs		= fec_enet_get_regs,
> @@ -2583,6 +2581,8 @@ static const struct ethtool_ops fec_enet_ethtool_ops
> = {
>  	.set_tunable		= fec_enet_set_tunable,
>  	.get_wol		= fec_enet_get_wol,
>  	.set_wol		= fec_enet_set_wol,
> +	.get_link_ksettings	= fec_enet_get_link_ksettings,
> +	.set_link_ksettings	= fec_enet_set_link_ksettings,
>  };
> 
>  static int fec_enet_ioctl(struct net_device *ndev, struct ifreq *rq, int cmd)
> --
> 1.7.4.4

Acked-by: Fugang Duan <fugang.duan@nxp.com>
