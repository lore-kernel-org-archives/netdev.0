From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] bgmac: add support for Byte Queue Limits
Date: Sat, 28 Sep 2013 16:03:20 -0700
Message-ID: <1380409400.3596.9.camel@edumazet-glaptop.roam.corp.google.com>
References: <1380407726-20691-1-git-send-email-hauke@hauke-m.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, zajec5@gmail.com, netdev@vger.kernel.org
To: Hauke Mehrtens <hauke@hauke-m.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f50.google.com ([209.85.160.50]:51664 "EHLO
	mail-pb0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752626Ab3I1XDV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Sep 2013 19:03:21 -0400
Received: by mail-pb0-f50.google.com with SMTP id uo5so3968057pbc.23
        for <netdev@vger.kernel.org>; Sat, 28 Sep 2013 16:03:21 -0700 (PDT)
In-Reply-To: <1380407726-20691-1-git-send-email-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-09-29 at 00:35 +0200, Hauke Mehrtens wrote:
> This makes it possible to use some more advanced queuing
> techniques with this driver.
> 
> When multi queue support will be added some changes to Byte Queue
> handling is needed.
> 
> Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
> ---
>  drivers/net/ethernet/broadcom/bgmac.c |   10 ++++++++++
>  1 file changed, 10 insertions(+)
> 
> diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethernet/broadcom/bgmac.c
> index 249468f..e5519f1 100644
> --- a/drivers/net/ethernet/broadcom/bgmac.c
> +++ b/drivers/net/ethernet/broadcom/bgmac.c
> @@ -164,6 +164,8 @@ static netdev_tx_t bgmac_dma_tx_add(struct bgmac *bgmac,
>  	if (--free_slots == 1)
>  		netif_stop_queue(net_dev);
>  
> +	netdev_sent_queue(net_dev, skb->len);
> +
>  	return NETDEV_TX_OK;
>  

Unfortunately, skb->len is unsafe : hardware might already sent the
packet and TX completion have freed it.

You must cache skb->len in a variable before allowing hardware to send
the frame.
