From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH v3 3/3] tg3: add support for Ethernet core in
 bcm4785
Date: Wed, 6 Feb 2013 18:06:08 -0800
Message-ID: <1360202768.796.6.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <1360190768-390-1-git-send-email-hauke@hauke-m.de>
 <1360190768-390-4-git-send-email-hauke@hauke-m.de>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=cp1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, mcarlson@broadcom.com, nsujir@broadcom.com,
	netdev@vger.kernel.org, m@bues.ch
To: "Hauke Mehrtens" <hauke@hauke-m.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1642 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751835Ab3BGCGq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Feb 2013 21:06:46 -0500
In-Reply-To: <1360190768-390-4-git-send-email-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-02-06 at 23:46 +0100, Hauke Mehrtens wrote: 
> @@ -16165,7 +16256,8 @@ static int tg3_test_dma(struct tg3 *tp)
>                         if (tg3_flag(tp, 40BIT_DMA_BUG) &&
>                             GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5704)
>                                 tp->dma_rwctrl |= 0x8000;
> -                       else if (ccval == 0x6 || ccval == 0x7)
> +                       else if ((ccval == 0x6 || ccval == 0x7) ||
> +                                tg3_flag(tp, ONE_DMA_AT_ONCE))

This code path is only for the older 5703 and 5704.  So it won't be
applicable for this ethernet core, right?

>                                 tp->dma_rwctrl |= DMA_RWCTRL_ONE_DMA;
>  
>                         if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5703) 
