From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 4/9] stmmac: add MMC support exported via ethtool (v2)
Date: Tue, 30 Aug 2011 16:26:44 +0100
Message-ID: <1314718004.2752.15.camel@bwh-desktop>
References: <1314714064-29101-1-git-send-email-peppe.cavallaro@st.com>
	 <1314714064-29101-5-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:40650 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755033Ab1H3P0r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2011 11:26:47 -0400
In-Reply-To: <1314714064-29101-5-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-08-30 at 16:20 +0200, Giuseppe CAVALLARO wrote:
> This patch adds the MMC management counters support.
> MMC module is an extension of the register address
> space and all the hardware counters can be accessed
> via ethtoo -S ethX.
> 
> Note that, the MMC interrupts remain masked and the logic
> to handle this kind of interrupt will be added later (if
> actually useful).
[...]
>  static void stmmac_ethtool_getdrvinfo(struct net_device *dev,
>  				      struct ethtool_drvinfo *info)
>  {
>  	struct stmmac_priv *priv = netdev_priv(dev);
>  
> -	if (!priv->plat->has_gmac)
> -		strcpy(info->driver, MAC100_ETHTOOL_NAME);
> -	else
> +	info->n_stats = STMMAC_STATS_LEN;
> +
> +	if (likely(priv->plat->has_gmac)) {

Using likely() and unlikely() in ethtool operations seems like a
pointless optimisation.

>  		strcpy(info->driver, GMAC_ETHTOOL_NAME);
> +		info->n_stats += STMMAC_MMC_STATS_LEN;
> +	} else
> +		strcpy(info->driver, MAC100_ETHTOOL_NAME);
>  
>  	strcpy(info->version, DRV_MODULE_VERSION);
>  	info->fw_version[0] = '\0';
> -	info->n_stats = STMMAC_STATS_LEN;
>  }
[...]

Don't bother initialising ethtool_drvinfo::n_stats.  The ethtool core
will do it by calling your get_sset_count implementation.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
