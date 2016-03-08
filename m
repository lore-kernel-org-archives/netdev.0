From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net] r8169:Remove unnecessary phy reset for pcie nic when
 setting link spped.
Date: Wed, 9 Mar 2016 00:48:55 +0100
Message-ID: <20160308234855.GA6182@electric-eye.fr.zoreil.com>
References: <1457427065-3699-1-git-send-email-hau@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org
To: Chunhao Lin <hau@realtek.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:57640 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750888AbcCHXtG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2016 18:49:06 -0500
Content-Disposition: inline
In-Reply-To: <1457427065-3699-1-git-send-email-hau@realtek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chunhao Lin <hau@realtek.com> :
> For pcie nic, after setting link speed and thers is no link  driver does not need
> to do phy reset untill link up.
> 
> For some pcie nics, to do this will also reset phy speed down counter and prevent
> phy from auto speed down.
> 
> This patch fix the issue reported in following link.
> https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1547151
> 
> Signed-off-by: Chunhao Lin <hau@realtek.com>
> ---
>  drivers/net/ethernet/realtek/r8169.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
> index dd2cf37..94f08f1 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
> @@ -1999,7 +1999,8 @@ static int rtl8169_set_speed(struct net_device *dev,
>  		goto out;
>  
>  	if (netif_running(dev) && (autoneg == AUTONEG_ENABLE) &&
> -	    (advertising & ADVERTISED_1000baseT_Full)) {
> +	    (advertising & ADVERTISED_1000baseT_Full) &&
> +	    !pci_is_pcie(tp->pci_dev)) {
>  		mod_timer(&tp->timer, jiffies + RTL8169_PHY_TIMEOUT);
>  	}
>  out:

Can you clarify:
- actually this patch does not care about the link at all. So when there's
  link no phy reset is needed either, right ?
- does "this" in "to do this" means that
  1. phy reset prevents phy from auto speed down
  2. avoiding phy reset prevents phy from auto speed down
  I would expect 1. from the rtl_wol_pll_power_down + rtl_speed_down +
  rtl8169_set_speed combo (i.e. we want the driver to allow auto speed down)
  but it's a bit ambiguous.

-- 
Ueimor
