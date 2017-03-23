From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: stmmac: add set_mac to the stmmac_ops
Date: Wed, 22 Mar 2017 19:29:46 -0700 (PDT)
Message-ID: <20170322.192946.905863899824397633.davem@davemloft.net>
References: <20170322132904.2687-1-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: clabbe.montjoie@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46954 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751440AbdCWC3s (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Mar 2017 22:29:48 -0400
In-Reply-To: <20170322132904.2687-1-clabbe.montjoie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Corentin Labbe <clabbe.montjoie@gmail.com>
Date: Wed, 22 Mar 2017 14:29:04 +0100

> @@ -2224,7 +2222,8 @@ static int stmmac_release(struct net_device *dev)
>  	free_dma_desc_resources(priv);
>  
>  	/* Disable the MAC Rx/Tx */
> -	stmmac_set_mac(priv->ioaddr, false);
> +	if (priv->hw->mac->set_mac)
> +		priv->hw->mac->set_mac(priv->ioaddr, false);
>  
>  	netif_carrier_off(dev);
>  
> @@ -3710,7 +3709,8 @@ int stmmac_dvr_remove(struct device *dev)
>  
>  	stmmac_stop_all_dma(priv);
>  
> -	stmmac_set_mac(priv->ioaddr, false);
> +	if (priv->hw->mac->set_mac)
> +		priv->hw->mac->set_mac(priv->ioaddr, false);
>  	netif_carrier_off(ndev);
>  	unregister_netdev(ndev);
>  	if (priv->plat->stmmac_rst)
> @@ -3761,7 +3761,8 @@ int stmmac_suspend(struct device *dev)
>  		priv->hw->mac->pmt(priv->hw, priv->wolopts);
>  		priv->irq_wake = 1;
>  	} else {
> -		stmmac_set_mac(priv->ioaddr, false);
> +		if (priv->hw->mac->set_mac)
> +			priv->hw->mac->set_mac(priv->ioaddr, false);
>  		pinctrl_pm_select_sleep_state(priv->device);
>  		/* Disable clock in case of PWM is off */
>  		clk_disable(priv->plat->pclk);

I'd say this is pretty much a required method, so it doesn't make any
sense to guard the calls with a NULL check.  Every implementation of
the MAC ops must at least set set_mac to stmmac_set_mac().

So please remove the checks, thanks.
