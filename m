From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] wan: dscc4: add checks for dma mapping errors
Date: Mon, 07 Aug 2017 14:06:40 -0700 (PDT)
Message-ID: <20170807.140640.71936308742422582.davem@davemloft.net>
References: <1501878204-24270-1-git-send-email-khoroshilov@ispras.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, ldv-project@linuxtesting.org
To: khoroshilov@ispras.ru
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1501878204-24270-1-git-send-email-khoroshilov@ispras.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alexey Khoroshilov <khoroshilov@ispras.ru>
Date: Fri,  4 Aug 2017 23:23:24 +0300

> The driver does not check if mapping dma memory succeed.
> The patch adds the checks and failure handling.
> 
> Found by Linux Driver Verification project (linuxtesting.org).
> 
> Signed-off-by: Alexey Khoroshilov <khoroshilov@ispras.ru>

This is a great example of why it can be irritating to see these
mechanical "bug fixes" for drivers very few people use and actually
test, which introduces new bugs.

> @@ -522,19 +522,27 @@ static inline int try_get_rx_skb(struct dscc4_dev_priv *dpriv,
>  	struct RxFD *rx_fd = dpriv->rx_fd + dirty;
>  	const int len = RX_MAX(HDLC_MAX_MRU);
>  	struct sk_buff *skb;
> -	int ret = 0;
> +	dma_addr_t addr;
>  
>  	skb = dev_alloc_skb(len);
>  	dpriv->rx_skbuff[dirty] = skb;

skb recorded here.

> +err_free_skb:
> +	dev_kfree_skb_any(skb);

Yet freed here in the error path.

dpriv->rx_skbuff[dirty] should not be set to 'skb' until all possibile
failure tests have passed.
