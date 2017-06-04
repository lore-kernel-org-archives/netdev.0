From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net/phy: Delete unused function phy_ethtool_gset
Date: Sun, 4 Jun 2017 10:20:59 -0700
Message-ID: <64be6e73-73c4-f83b-1c77-93d367b4c9d6@gmail.com>
References: <20170604171016.3910-1-yuval.shaia@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: Yuval Shaia <yuval.shaia@oracle.com>, andrew@lunn.ch,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:34037 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750931AbdFDRVB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Jun 2017 13:21:01 -0400
Received: by mail-oi0-f68.google.com with SMTP id d99so7162017oic.1
        for <netdev@vger.kernel.org>; Sun, 04 Jun 2017 10:21:01 -0700 (PDT)
In-Reply-To: <20170604171016.3910-1-yuval.shaia@oracle.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 06/04/2017 10:10 AM, Yuval Shaia wrote:
> Signed-off-by: Yuval Shaia <yuval.shaia@oracle.com>

A commit message that just says: it's unused, so remove it would be
nice. You seem to have missed Documentation/networking/phy.txt in this
patch, do you mind resubmitting with that fixed?

Finally, the subject should be:

net: phy: Delete unused function phy_ethtool_gset

to be (semi) consistent with past submissions done to these files. Thanks!

> ---
>  drivers/net/phy/phy.c | 24 ------------------------
>  include/linux/phy.h   |  1 -
>  2 files changed, 25 deletions(-)
> 
> diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
> index 9c372bf..8e26af5 100644
> --- a/drivers/net/phy/phy.c
> +++ b/drivers/net/phy/phy.c
> @@ -484,30 +484,6 @@ int phy_ethtool_ksettings_set(struct phy_device *phydev,
>  }
>  EXPORT_SYMBOL(phy_ethtool_ksettings_set);
>  
> -int phy_ethtool_gset(struct phy_device *phydev, struct ethtool_cmd *cmd)
> -{
> -	cmd->supported = phydev->supported;
> -
> -	cmd->advertising = phydev->advertising;
> -	cmd->lp_advertising = phydev->lp_advertising;
> -
> -	ethtool_cmd_speed_set(cmd, phydev->speed);
> -	cmd->duplex = phydev->duplex;
> -	if (phydev->interface == PHY_INTERFACE_MODE_MOCA)
> -		cmd->port = PORT_BNC;
> -	else
> -		cmd->port = PORT_MII;
> -	cmd->phy_address = phydev->mdio.addr;
> -	cmd->transceiver = phy_is_internal(phydev) ?
> -		XCVR_INTERNAL : XCVR_EXTERNAL;
> -	cmd->autoneg = phydev->autoneg;
> -	cmd->eth_tp_mdix_ctrl = phydev->mdix_ctrl;
> -	cmd->eth_tp_mdix = phydev->mdix;
> -
> -	return 0;
> -}
> -EXPORT_SYMBOL(phy_ethtool_gset);
> -
>  void phy_ethtool_ksettings_get(struct phy_device *phydev,
>  			       struct ethtool_link_ksettings *cmd)
>  {
> diff --git a/include/linux/phy.h b/include/linux/phy.h
> index 4ec07a6..804851c 100644
> --- a/include/linux/phy.h
> +++ b/include/linux/phy.h
> @@ -843,7 +843,6 @@ void phy_start_machine(struct phy_device *phydev);
>  void phy_stop_machine(struct phy_device *phydev);
>  void phy_trigger_machine(struct phy_device *phydev, bool sync);
>  int phy_ethtool_sset(struct phy_device *phydev, struct ethtool_cmd *cmd);
> -int phy_ethtool_gset(struct phy_device *phydev, struct ethtool_cmd *cmd);
>  void phy_ethtool_ksettings_get(struct phy_device *phydev,
>  			       struct ethtool_link_ksettings *cmd);
>  int phy_ethtool_ksettings_set(struct phy_device *phydev,
> 

-- 
Florian
