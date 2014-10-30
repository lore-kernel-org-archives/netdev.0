From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] stmmac: pci: set default of the filter bins
Date: Thu, 30 Oct 2014 19:44:53 -0400 (EDT)
Message-ID: <20141030.194453.129639650935738765.davem@davemloft.net>
References: <1414661965-1140-1-git-send-email-andriy.shevchenko@linux.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, netdev@vger.kernel.org,
	hock.leong.kweh@intel.com, vbridgers2013@gmail.com
To: andriy.shevchenko@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60945 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161293AbaJ3Xoz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2014 19:44:55 -0400
In-Reply-To: <1414661965-1140-1-git-send-email-andriy.shevchenko@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Date: Thu, 30 Oct 2014 11:39:25 +0200

> @@ -32,7 +32,10 @@ static struct stmmac_dma_cfg dma_cfg;
>  
>  static void stmmac_default_data(void)
>  {
> +	struct plat_stmmacenet_data *plat = &plat_dat;
> +
>  	memset(&plat_dat, 0, sizeof(struct plat_stmmacenet_data));
> +
>  	plat_dat.bus_id = 1;
>  	plat_dat.phy_addr = 0;
>  	plat_dat.interface = PHY_INTERFACE_MODE_GMII;
> @@ -47,6 +50,12 @@ static void stmmac_default_data(void)
>  	dma_cfg.pbl = 32;
>  	dma_cfg.burst_len = DMA_AXI_BLEN_256;
>  	plat_dat.dma_cfg = &dma_cfg;
> +
> +	/* Set default value for multicast hash bins */
> +	plat->multicast_filter_bins = HASH_TABLE_SIZE;
> +
> +	/* Set default value for unicast filter entries */
> +	plat->unicast_filter_entries = 1;

Don't do this.

The rest of the function goes "plat_dat.foo" so it looks terribly
inconsistent when you add the local variable to dereference it like
this.

So just do "plat_dat.multicast_filter_bins = x;" etc.
