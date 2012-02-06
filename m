From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5 2/5] netdev: ethernet dev_alloc_skb to
 netdev_alloc_skb
Date: Mon, 06 Feb 2012 11:49:17 -0500 (EST)
Message-ID: <20120206.114917.1450321525231150955.davem@davemloft.net>
References: <cf736034e7bd407297e2ea9fbf247fb410eb7b39.1328445742.git.netdev@pradeepdalvi.com>
	<59b9c48e067528d94b260b044e1b375c56c97040.1328445742.git.netdev@pradeepdalvi.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@pradeepdalvi.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <59b9c48e067528d94b260b044e1b375c56c97040.1328445742.git.netdev@pradeepdalvi.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Pradeep A. Dalvi" <netdev@pradeepdalvi.com>
Date: Sun,  5 Feb 2012 18:20:10 +0530

> From: Pradeep A Dalvi <netdev@pradeepdalvi.com>
> 
> Replaced deprecating dev_alloc_skb with netdev_alloc_skb in drivers/net/ethernet
>   - Removed extra skb->dev = dev after netdev_alloc_skb
> 
> Signed-off-by: Pradeep A Dalvi <netdev@pradeepdalvi.com>

Applied, but again I had to fix things:

> -    p = dev_alloc_skb(IEEE802_3_SZ + DE4X5_ALIGN + 2);
> +	p = netdev_alloc_skb(dev, IEEE802_3_SZ + DE4X5_ALIGN + 2);
 ...
> -    p = dev_alloc_skb(len + 2);
> +	p = netdev_alloc_skb(dev, len + 2);

Leave existing indentation alone.

> -		skb = dev_alloc_skb(ugeth->ug_info->uf_info.max_rx_buf_length +
> -				    UCC_GETH_RX_DATA_BUF_ALIGNMENT);
> +		skb = netdev_alloc_skb(ugeth->ndev,
> +				ugeth->ug_info->uf_info.max_rx_buf_length +
> +				UCC_GETH_RX_DATA_BUF_ALIGNMENT);

Line up subsequent lines of a multiline series of function arguments
properly, each should start at the first column after the function calls
openning parenthesis.
