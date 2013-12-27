From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next] mdio: unused ethtool functions
Date: Fri, 27 Dec 2013 10:06:43 +0100
Message-ID: <1388135203.26981.22.camel@deadeye.wl.decadent.org.uk>
References: <20131226101241.5f38e392@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:15757 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754060Ab3L0JGt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Dec 2013 04:06:49 -0500
In-Reply-To: <20131226101241.5f38e392@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-12-26 at 10:12 -0800, Stephen Hemminger wrote:
> Use it or lose it.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

Right, this was called by sfc for a while but not since 2.6.33 as we set
all the autoneg bits at once.

Ben.

> ---
>  drivers/net/mdio.c   |   28 ----------------------------
>  include/linux/mdio.h |    3 ---
>  2 files changed, 31 deletions(-)
> 
> --- a/drivers/net/mdio.c	2013-12-24 15:37:35.779661759 -0800
> +++ b/drivers/net/mdio.c	2013-12-24 15:38:26.054970175 -0800
> @@ -342,34 +342,6 @@ void mdio45_ethtool_gset_npage(const str
>  EXPORT_SYMBOL(mdio45_ethtool_gset_npage);
>  
>  /**
> - * mdio45_ethtool_spauseparam_an - set auto-negotiated pause parameters
> - * @mdio: MDIO interface
> - * @ecmd: Ethtool request structure
> - *
> - * This function assumes that the PHY has an auto-negotiation MMD.  It
> - * will enable and disable advertising of flow control as appropriate.
> - */
> -void mdio45_ethtool_spauseparam_an(const struct mdio_if_info *mdio,
> -				   const struct ethtool_pauseparam *ecmd)
> -{
> -	int adv, old_adv;
> -
> -	WARN_ON(!(mdio->mmds & MDIO_DEVS_AN));
> -
> -	old_adv = mdio->mdio_read(mdio->dev, mdio->prtad, MDIO_MMD_AN,
> -				  MDIO_AN_ADVERTISE);
> -	adv = ((old_adv & ~(ADVERTISE_PAUSE_CAP | ADVERTISE_PAUSE_ASYM)) |
> -	       mii_advertise_flowctrl((ecmd->rx_pause ? FLOW_CTRL_RX : 0) |
> -				      (ecmd->tx_pause ? FLOW_CTRL_TX : 0)));
> -	if (adv != old_adv) {
> -		mdio->mdio_write(mdio->dev, mdio->prtad, MDIO_MMD_AN,
> -				 MDIO_AN_ADVERTISE, adv);
> -		mdio45_nway_restart(mdio);
> -	}
> -}
> -EXPORT_SYMBOL(mdio45_ethtool_spauseparam_an);
> -
> -/**
>   * mdio_mii_ioctl - MII ioctl interface for MDIO (clause 22 or 45) PHYs
>   * @mdio: MDIO interface
>   * @mii_data: MII ioctl data structure
> --- a/include/linux/mdio.h	2013-12-24 15:37:35.779661759 -0800
> +++ b/include/linux/mdio.h	2013-12-24 15:38:26.054970175 -0800
> @@ -70,9 +70,6 @@ extern int mdio45_nway_restart(const str
>  extern void mdio45_ethtool_gset_npage(const struct mdio_if_info *mdio,
>  				      struct ethtool_cmd *ecmd,
>  				      u32 npage_adv, u32 npage_lpa);
> -extern void
> -mdio45_ethtool_spauseparam_an(const struct mdio_if_info *mdio,
> -			      const struct ethtool_pauseparam *ecmd);
>  
>  /**
>   * mdio45_ethtool_gset - get settings for ETHTOOL_GSET

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
