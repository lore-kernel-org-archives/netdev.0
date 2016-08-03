From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH] [v6] net: emac: emac gigabit ethernet controller driver
Date: Wed, 3 Aug 2016 16:24:22 -0500
Message-ID: <57A26106.50206@codeaurora.org>
References: <1466812008-26686-1-git-send-email-timur@codeaurora.org>
 <11472258.9SNjZdPb6l@wuerfel> <57742C84.6000903@codeaurora.org>
 <79189959.nJygzEHqi7@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
	linux-arm-msm@vger.kernel.org, sdharia@codeaurora.org,
	shankerd@codeaurora.org, vikrams@codeaurora.org,
	cov@codeaurora.org, gavidov@codeaurora.org, robh+dt@kernel.org,
	andrew@lunn.ch, bjorn.andersson@linaro.org, mlangsdo@redhat.com,
	jcm@redhat.com, agross@codeaurora.org, davem@davemloft.net,
	f.fainelli@gmail.com, catalin.marinas@arm.com
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-arm-msm-owner@vger.kernel.org>
In-Reply-To: <79189959.nJygzEHqi7@wuerfel>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arnd Bergmann wrote:
> As I said, this is inherently driver specific. If setting the 64-bit
> mask fails, the driver itself needs to fall back to the 32-bit mask
> so it can allocate buffers from ZONE_DMA instead of ZONE_NORMAL.

I just posted a v7 of my patch, but I forgot to fix the dma_set_mask 
call.  I'll post a v8 soon, but before I do, what do you think of this:

/* The EMAC itself is capable of 64-bit DMA, so try that first. */
ret = dma_set_mask_and_coherent(&pdev->dev, DMA_BIT_MASK(64));
if (ret) {
         /* Some platforms may restrict the EMAC's address bus to less
          * then the size of DDR. In this case, we need to try a
          * smaller mask.  We could try every possible smaller mask,
          * but that's overkill.  Instead, just fall to 32-bit, which
          * should always work.
          */
         ret = dma_set_mask_and_coherent(&pdev->dev, DMA_BIT_MASK(32));
         if (ret) {
                 dev_err(&pdev->dev, "could not set DMA mask\n");
                 return ret;
         }
}


-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
