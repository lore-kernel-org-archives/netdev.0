From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] [v6] net: emac: emac gigabit ethernet controller driver
Date: Wed, 29 Jun 2016 10:17:07 +0200
Message-ID: <5301045.3F9gkJcz60@wuerfel>
References: <1466812008-26686-1-git-send-email-timur@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
	linux-arm-msm@vger.kernel.org, sdharia@codeaurora.org,
	shankerd@codeaurora.org, vikrams@codeaurora.org,
	cov@codeaurora.org, gavidov@codeaurora.org, robh+dt@kernel.org,
	andrew@lunn.ch, bjorn.andersson@linaro.org, mlangsdo@redhat.com,
	jcm@redhat.com, agross@codeaurora.org, davem@davemloft.net,
	f.fainelli@gmail.com
To: Timur Tabi <timur@codeaurora.org>
Return-path: <linux-arm-msm-owner@vger.kernel.org>
In-Reply-To: <1466812008-26686-1-git-send-email-timur@codeaurora.org>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday, June 24, 2016 6:46:48 PM CEST Timur Tabi wrote:
> +       /* The EMAC itself is capable of 64-bit DMA. If the SOC limits that
> +        * range, then we expect platform code to adjust the mask accordingly.
> +        */
> +       ret = dma_set_mask_and_coherent(&pdev->dev, DMA_BIT_MASK(64));
> +       if (ret) {
> +               dev_err(&pdev->dev, "could not set DMA mask\n");
> +               return ret;
> +       }
> 

The comment does not match the code: if the platform has no IOMMU
and the bus limit is smaller than the memory, dma_set_mask_and_coherent()
will fail, and the driver should instead ensure that the buffers are
allocated from the 32-bit area.

Alternatively, adjust the comment to explain that this is a limitation
in the driver that can be lifted if necessary.

	Arnd 
