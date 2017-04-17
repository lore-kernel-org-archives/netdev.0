From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: natsemi: ns83820: add checks for dma mapping error
Date: Mon, 17 Apr 2017 15:17:43 -0400 (EDT)
Message-ID: <20170417.151743.1779341653983811894.davem@davemloft.net>
References: <1492210250-17200-1-git-send-email-khoroshilov@ispras.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        ldv-project@linuxtesting.org
To: khoroshilov@ispras.ru
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1492210250-17200-1-git-send-email-khoroshilov@ispras.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Date: Sat, 15 Apr 2017 01:50:50 +0300

> @@ -1136,6 +1141,10 @@ static netdev_tx_t ns83820_hard_start_xmit(struct sk_buff *skb,
>  	if (nr_frags)
>  		len -= skb->data_len;
>  	buf = pci_map_single(dev->pci_dev, skb->data, len, PCI_DMA_TODEVICE);
> +	if (pci_dma_mapping_error(dev->pci_dev, buf)) {
> +		dev_kfree_skb_any(skb);
> +		return NETDEV_TX_OK;
> +	}
>  
>  	first_desc = dev->tx_descs + (free_idx * DESC_SIZE);
>  

You need to also add this check for the skb_map_dma_frag() calls below
this line, and therefore you'll need to add unwind on such a failure.
