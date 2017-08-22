From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC net] fsl/man: Inherit parent device and of_node
Date: Tue, 22 Aug 2017 10:26:10 -0700 (PDT)
Message-ID: <20170822.102610.235105979872147384.davem@davemloft.net>
References: <20170819001255.20755-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, madalin.bucur@nxp.com,
        junote@outlook.com, igal.liberman@freescale.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38302 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751061AbdHVR0M (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 13:26:12 -0400
In-Reply-To: <20170819001255.20755-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Fri, 18 Aug 2017 17:12:55 -0700

> @@ -623,6 +623,8 @@ static struct platform_device *dpaa_eth_add_device(int fman_id,
>  		goto no_mem;
>  	}
>  
> +	pdev->dev.of_node = node;
> +	pdev->dev.parent = priv->dev;
>  	set_dma_ops(&pdev->dev, get_dma_ops(priv->dev));
>  
>  	ret = platform_device_add_data(pdev, &data, sizeof(data));

I guess since we allocate and manage the platform device here, we can
fumble around safely with it's device node pointer and parent.

So this should be ok.
