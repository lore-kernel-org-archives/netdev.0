From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] r8169: set coherent DMA mask as well as streaming DMA
 mask
Date: Fri, 14 Oct 2016 09:31:01 -0400 (EDT)
Message-ID: <20161014.093101.1348173909013700977.davem@davemloft.net>
References: <1476445170-4496-1-git-send-email-ard.biesheuvel@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, nic_swsd@realtek.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: ard.biesheuvel@linaro.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47030 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755366AbcJNNbH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2016 09:31:07 -0400
In-Reply-To: <1476445170-4496-1-git-send-email-ard.biesheuvel@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Date: Fri, 14 Oct 2016 12:39:30 +0100

> PCI devices that are 64-bit DMA capable should set the coherent
> DMA mask as well as the streaming DMA mask. On some architectures,
> these are managed separately, and so the coherent DMA mask will be
> left at its default value of 32 if it is not set explicitly. This
> results in errors such as
> 
>      r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
>      hwdev DMA mask = 0x00000000ffffffff, dev_addr = 0x00000080fbfff000
>      swiotlb: coherent allocation failed for device 0000:02:00.0 size=4096
>      CPU: 0 PID: 1062 Comm: systemd-udevd Not tainted 4.8.0+ #35
>      Hardware name: AMD Seattle/Seattle, BIOS 10:53:24 Oct 13 2016
> 
> on systems without memory that is 32-bit addressable by PCI devices.
> 
> Signed-off-by: Ard Biesheuvel <ard.biesheuvel@linaro.org>
 ...
> @@ -8281,6 +8282,8 @@ static int rtl_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
>  		dev->features |= NETIF_F_HIGHDMA;
>  	} else {
>  		rc = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
> +		if (!rc)
> +			rc = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(32));

As you state 32-bit is the default, therefore this part of your patch is unnecessary.
