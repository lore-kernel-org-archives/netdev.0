From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] gianfar: handle map error in gfar_start_xmit()
Date: Tue, 09 Dec 2014 15:39:03 -0500 (EST)
Message-ID: <20141209.153903.1672471330337681259.davem@davemloft.net>
References: <1417775874-17775-1-git-send-email-asolokha@kb.kras.ru>
	<1417775874-17775-3-git-send-email-asolokha@kb.kras.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: claudiu.manoil@freescale.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: asolokha@kb.kras.ru
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1417775874-17775-3-git-send-email-asolokha@kb.kras.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arseny Solokha <asolokha@kb.kras.ru>
Date: Fri,  5 Dec 2014 17:37:54 +0700

> @@ -2296,6 +2296,12 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
>  						   0,
>  						   frag_len,
>  						   DMA_TO_DEVICE);
> +			if (unlikely(dma_mapping_error(priv->dev, bufaddr))) {
> +				/* As DMA mapping failed, pretend the TX path
> +				 * is busy to retry later
> +				 */
> +				return NETDEV_TX_BUSY;
> +			}

You are not "busy", you are dropping the packet due to insufficient system
resources.

Therefore the appropriate thing to do is to free the SKB, increment
the drop statistical counter, and return NETDEV_TX_OK.
