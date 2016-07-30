From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 04/15] ethernet: aurora: nb8800: add missing
 of_node_put after calling of_parse_phandle
Date: Fri, 29 Jul 2016 23:13:34 -0700 (PDT)
Message-ID: <20160729.231334.379751093388521243.davem@davemloft.net>
References: <1469586048-15697-1-git-send-email-peter.chen@nxp.com>
	<1469586048-15697-5-git-send-email-peter.chen@nxp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vbridger@opensource.altera.com,
	isubramanian@apm.com, kchudgar@apm.com, yisen.zhuang@huawei.com,
	salil.mehta@huawei.com, thomas.petazzoni@free-electrons.com,
	sergei.shtylyov@cogentembedded.com, peppe.cavallaro@st.com,
	alexandre.torgue@st.com, mugunthanvnm@ti.com, tremyfr@gmail.com,
	wxt@rock-chips.com, arnd@arndb.de, david.daney@cavium.com,
	huangdaode@hisilicon.com, jszhang@marvell.com
To: peter.chen@nxp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34016 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750758AbcG3GNi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jul 2016 02:13:38 -0400
In-Reply-To: <1469586048-15697-5-git-send-email-peter.chen@nxp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Chen <peter.chen@nxp.com>
Date: Wed, 27 Jul 2016 10:20:37 +0800

> diff --git a/drivers/net/ethernet/aurora/nb8800.c b/drivers/net/ethernet/aurora/nb8800.c
> index 0d4ea92..d15d96b 100644
> --- a/drivers/net/ethernet/aurora/nb8800.c
> +++ b/drivers/net/ethernet/aurora/nb8800.c
> @@ -1006,6 +1006,7 @@ static int nb8800_stop(struct net_device *dev)
>  
>  	netif_stop_queue(dev);
>  	napi_disable(&priv->napi);
> +	of_node_put(priv->phy_node);
>  
>  	nb8800_dma_stop(dev);
>  	nb8800_mac_rx(dev, false);

This is broken.  The priv->phy_node reference is taken in the probe function,
therefore you have to drop that reference in the "remove" function not the
"stop" function.

I'm just looking over basic details of this patch series, and along with some
other feedback you've received, it looks like you really didn't put a lot of
auditing into the changes you are making.

Please go over this series one more time and resubmit the entire thing after
everything is sorted out and double-checked.

Thank you.
