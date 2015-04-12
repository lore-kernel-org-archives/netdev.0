From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 4/4] bgmac: fix DMA rx corruption
Date: Sun, 12 Apr 2015 14:11:44 +0300
Message-ID: <552A52F0.4080803@cogentembedded.com>
References: <1428833292-15356-1-git-send-email-nbd@openwrt.org> <1428833292-15356-4-git-send-email-nbd@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: zajec5@gmail.com, hauke@hauke-m.de
To: Felix Fietkau <nbd@openwrt.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f54.google.com ([209.85.215.54]:34715 "EHLO
	mail-la0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751376AbbDLLLr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Apr 2015 07:11:47 -0400
Received: by laat2 with SMTP id t2so39532438laa.1
        for <netdev@vger.kernel.org>; Sun, 12 Apr 2015 04:11:46 -0700 (PDT)
In-Reply-To: <1428833292-15356-4-git-send-email-nbd@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 4/12/2015 1:08 PM, Felix Fietkau wrote:

> The driver needs to inform the hardware about the first invalid (not yet
> filled) rx slot, by writing its DMA descriptor pointer offset to the
> BGMAC_DMA_RX_INDEX register.

> This register was set to a value exceeding the rx ring size, effectively
> allowing the hardware constant access to the full ring, regardless of
> which slots are initialized.

> Fix this by updating the register in bgmac_dma_rx_setup_desc.

> Signed-off-by: Felix Fietkau <nbd@openwrt.org>
> ---
>   drivers/net/ethernet/broadcom/bgmac.c | 14 +++++++-------
>   1 file changed, 7 insertions(+), 7 deletions(-)

> diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethernet/broadcom/bgmac.c
> index e332de8..856ceee 100644
> --- a/drivers/net/ethernet/broadcom/bgmac.c
> +++ b/drivers/net/ethernet/broadcom/bgmac.c
> @@ -380,6 +380,12 @@ static void bgmac_dma_rx_setup_desc(struct bgmac *bgmac,
>   	dma_desc->addr_high = cpu_to_le32(upper_32_bits(ring->slots[desc_idx].dma_addr));
>   	dma_desc->ctl0 = cpu_to_le32(ctl0);
>   	dma_desc->ctl1 = cpu_to_le32(ctl1);
> +
> +	desc_idx = (desc_idx + 1) % BGMAC_RX_RING_SLOTS;
> +
> +	bgmac_write(bgmac, ring->mmio_base + BGMAC_DMA_RX_INDEX,
> +			ring->index_base +
> +			desc_idx * sizeof(struct bgmac_dma_desc));

    The continuation lines should start on the next column after ( on the 
first line.

[...]

WBR, Sergei
