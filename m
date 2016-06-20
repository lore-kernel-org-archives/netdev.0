From: Shanker Donthineni <shankerd@codeaurora.org>
Subject: Re: [PATCH] [v5] net: emac: emac gigabit ethernet controller driver
Date: Mon, 20 Jun 2016 13:04:25 -0500
Message-ID: <57683029.1090601@codeaurora.org>
References: <1465942955-22988-1-git-send-email-timur@codeaurora.org>
 <20160619141757.GA4249@rob-hp-laptop> <57682AC3.4040003@codeaurora.org>
Reply-To: shankerd@codeaurora.org
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
	linux-arm-msm@vger.kernel.org, sdharia@codeaurora.org,
	vikrams@codeaurora.org, cov@codeaurora.org, gavidov@codeaurora.org,
	andrew@lunn.ch, bjorn.andersson@linaro.org, mlangsdo@redhat.com,
	jcm@redhat.com, agross@codeaurora.org, davem@davemloft.net,
	f.fainelli@gmail.com
To: Timur Tabi <timur@codeaurora.org>, Rob Herring <robh@kernel.org>
Return-path: <linux-arm-msm-owner@vger.kernel.org>
In-Reply-To: <57682AC3.4040003@codeaurora.org>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Timur,

I think, the device driver is responsible for setting the right DMA_MASK 
based on the underlying hardware capability if your driver wants to 
support 64bit DMA.

Example code in drivers/usb/host/xhci.c:

         /* Set dma_mask and coherent_dma_mask to 64-bits,
          * if xHC supports 64-bit addressing */
         if (HCC_64BIT_ADDR(xhci->hcc_params) &&
                         !dma_set_mask(dev, DMA_BIT_MASK(64))) {
                 xhci_dbg(xhci, "Enabling 64-bit DMA addresses.\n");
                 dma_set_coherent_mask(dev, DMA_BIT_MASK(64));
         } else {
                 /*
                  * This is to avoid error in cases where a 32-bit USB
                  * controller is used on a 64-bit capable system.
                  */
                 retval = dma_set_mask(dev, DMA_BIT_MASK(32));



On 06/20/2016 12:41 PM, Timur Tabi wrote:
> Rob Herring wrote:
>>> >+        dma-ranges = <0 0 0xffffffff>;
>> I believe dma-ranges is supposed to be in the bus (parent) node.
>
> Maybe I'm just going to be perpetually confused by dma-ranges, but how 
> can I specify that the emac has a different DMA range from another SOC 
> device, if dma-ranges is in the parent node?
>
> The EMAC itself is capable of 64-bit DMA internally (I should have 
> included a dma_set_mask call with DMA_BIT_MASK(64) in the driver). 
> However, the platform typically limits this range.  On FSM9900 and 
> QDF2432, it's 32 bits.  On the next server chip, it'll be the full 64 
> bits.  I need some way to handle that.
>

-- 
Shanker Donthineni
Qualcomm Technologies, Inc. on behalf of Qualcomm Innovation Center, Inc.
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum, a Linux Foundation Collaborative Project
