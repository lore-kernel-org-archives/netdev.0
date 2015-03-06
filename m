From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [PATCH] bgmac: ratelimit warning messages
Date: Sat, 7 Mar 2015 00:27:46 +0100
Message-ID: <CACna6rz32WFHNNRLFNDv2E6RBcT_7vFYTOEu66ubvUCQz48udw@mail.gmail.com>
References: <1425665874-14870-1-git-send-email-peter.senna@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Hauke Mehrtens <hauke@hauke-m.de>,
	w-lkml@lebenslange-mailadresse.de, Joe Perches <joe@perches.com>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Peter Senna Tschudin <peter.senna@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f180.google.com ([209.85.223.180]:34154 "EHLO
	mail-ie0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752680AbbCFX1r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Mar 2015 18:27:47 -0500
In-Reply-To: <1425665874-14870-1-git-send-email-peter.senna@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6 March 2015 at 19:17, Peter Senna Tschudin <peter.senna@gmail.com> wrote:
> On my test environment the troughput of a file transfer drops from
> 4.4Mbps to 116Kbps due the number of repeated warning messages.
> Adding printk_ratelimit() solves the issue without removing the
> warning message.
>
> Signed-off-by: Peter Senna Tschudin <peter.senna@gmail.com>
> ---
>  drivers/net/ethernet/broadcom/bgmac.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
>
> diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethernet/broadcom/bgmac.c
> index 676ffe0..d1a259b 100644
> --- a/drivers/net/ethernet/broadcom/bgmac.c
> +++ b/drivers/net/ethernet/broadcom/bgmac.c
> @@ -302,7 +302,7 @@ static int bgmac_dma_rx_skb_for_slot(struct bgmac *bgmac,
>         slot->skb = skb;
>         slot->dma_addr = dma_addr;
>
> -       if (slot->dma_addr & 0xC0000000)
> +       if ((slot->dma_addr & 0xC0000000) && printk_ratelimit())
>                 bgmac_warn(bgmac, "DMA address using 0xC0000000 bit(s), it may need translation trick\n");
>
>         return 0;

Nack. Please just drop this code.

>From what I understand network works for you. I've also checked
Broadcom's open source code, and on SoC we can always safely write
whole low 32b.
