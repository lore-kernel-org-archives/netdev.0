From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] natsemi: add checks for dma mapping errors
Date: Fri, 18 Dec 2015 21:36:07 -0500 (EST)
Message-ID: <20151218.213607.1270121670262037282.davem@davemloft.net>
References: <1450475737-5959-1-git-send-email-khoroshilov@ispras.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ldv-project@linuxtesting.org
To: khoroshilov@ispras.ru
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1450475737-5959-1-git-send-email-khoroshilov@ispras.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Date: Sat, 19 Dec 2015 00:55:37 +0300

> @@ -2093,6 +2099,10 @@ static netdev_tx_t start_tx(struct sk_buff *skb, struct net_device *dev)
>  	np->tx_skbuff[entry] = skb;
>  	np->tx_dma[entry] = pci_map_single(np->pci_dev,
>  				skb->data,skb->len, PCI_DMA_TODEVICE);
> +	if (pci_dma_mapping_error(np->pci_dev, np->tx_dma[entry])) {
> +		np->tx_skbuff[entry] = NULL;
> +		return NETDEV_TX_BUSY;
> +	}
>  
>  	np->tx_ring[entry].addr = cpu_to_le32(np->tx_dma[entry]);
>  

Returning NETDEV_TX_BUSY and freeing the SKB will crash the system.

NETDEV_TX_BUSY is only for buggy drivers that do not manage their
TX ring busy condition correctly, and thus need retries.
