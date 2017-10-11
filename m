From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/4] dpaa_eth: change device used
Date: Wed, 11 Oct 2017 14:02:03 -0700 (PDT)
Message-ID: <20171011.140203.578840078366210432.davem@davemloft.net>
References: <1507644618-32006-1-git-send-email-madalin.bucur@nxp.com>
        <1507644618-32006-4-git-send-email-madalin.bucur@nxp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, junote@outlook.com,
        linux-kernel@vger.kernel.org
To: madalin.bucur@nxp.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1507644618-32006-4-git-send-email-madalin.bucur@nxp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Madalin Bucur <madalin.bucur@nxp.com>
Date: Tue, 10 Oct 2017 17:10:17 +0300

> @@ -2696,7 +2681,13 @@ static int dpaa_eth_probe(struct platform_device *pdev)
>  	int err = 0, i, channel;
>  	struct device *dev;
>  
> -	dev = &pdev->dev;
> +	/* device used for DMA mapping */
> +	dev = pdev->dev.parent;
> +	err = dma_coerce_mask_and_coherent(dev, DMA_BIT_MASK(40));
> +	if (err) {
> +		dev_err(dev, "dma_coerce_mask_and_coherent() failed\n");
> +		goto dev_mask_failed;
> +	}
>  
>  	/* Allocate this early, so we can store relevant information in
>  	 * the private area

Since you are moving this code up before the netdev allocation, you must
adjust the failure path goto label used.

Your change as-is will cause an OOPS because we'll pass a NULL pointer
to free_netdev().
