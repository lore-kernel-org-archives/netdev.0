From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 05/12] ftgmac100: Pad small frames properly
Date: Fri, 7 Apr 2017 06:05:00 -0700
Message-ID: <09187038-06b1-82d2-1fda-1fea1c119a0a@gmail.com>
References: <20170407033105.29558-1-benh@kernel.crashing.org>
 <20170407033105.29558-6-benh@kernel.crashing.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:34410 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753505AbdDGNFD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Apr 2017 09:05:03 -0400
Received: by mail-io0-f196.google.com with SMTP id n76so7417288ioe.1
        for <netdev@vger.kernel.org>; Fri, 07 Apr 2017 06:05:03 -0700 (PDT)
In-Reply-To: <20170407033105.29558-6-benh@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 04/06/2017 08:30 PM, Benjamin Herrenschmidt wrote:
> Rather than just transmitting garbage past the end of the small
> packet.
> 
> Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> ---
>  drivers/net/ethernet/faraday/ftgmac100.c | 7 +++++++
>  1 file changed, 7 insertions(+)
> 
> diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
> index 6c71726..3f2172f 100644
> --- a/drivers/net/ethernet/faraday/ftgmac100.c
> +++ b/drivers/net/ethernet/faraday/ftgmac100.c
> @@ -636,6 +636,13 @@ static int ftgmac100_hard_start_xmit(struct sk_buff *skb,
>  	struct ftgmac100_txdes *txdes;
>  	dma_addr_t map;
>  
> +	/* The HW doesn't pad small frames */
> +	if (skb_padto(skb, ETH_ZLEN) < 0) {
> +		netdev->stats.tx_dropped++;
> +		return NETDEV_TX_OK;
> +	}

You may want to use skb_put_padto() which also takes care of bumping
skb->len accordingly, in case that makes a difference for the ftgmac100
hardware.
-- 
Florian
