From: "Lino Sanfilippo" <LinoSanfilippo-Mmb7MZpHnFY@public.gmane.org>
Subject: Aw: [PATCH v2] ethernet:arc: Fix racing of TX ring buffer
Date: Tue, 17 May 2016 18:36:11 +0200
Message-ID: <trinity-eed4d6ab-f658-4f47-94ff-5162845ba335-1463502971177@3capp-gmx-bs64>
References: <20160517152520.GA2750@debian-dorm>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org,
 romieu-W8zweXLXuWQS+FvcfC7Uqw@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, wxt-TNX95d0MmH7DzftRWevZcw@public.gmane.org
To: "Shuyu Wei" <wsy2220-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rockchip-bounces+glpar-linux-rockchip=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
In-Reply-To: <20160517152520.GA2750@debian-dorm>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-rockchip>,
 <mailto:linux-rockchip-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-rockchip/>
List-Post: <mailto:linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:linux-rockchip-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-rockchip>,
 <mailto:linux-rockchip-request-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org?subject=subscribe>
Sender: "Linux-rockchip" <linux-rockchip-bounces-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
Errors-To: linux-rockchip-bounces+glpar-linux-rockchip=m.gmane.org-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

> Von: "Shuyu Wei" <wsy2220-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> @@ -685,13 +684,15 @@ static int arc_emac_tx(struct sk_buff *skb, struct net_device *ndev)
>  	wmb();
>  
>  	skb_tx_timestamp(skb);
> +	priv->tx_buff[*txbd_curr].skb = skb;
> +
> +	dma_wmb();
>  
>  	*info = cpu_to_le32(FOR_EMAC | FIRST_OR_LAST_MASK | len);
>  
>  	/* Make sure info word is set */
>  	wmb();
>  
> -	priv->tx_buff[*txbd_curr].skb = skb;
>  
>  	/* Increment index to point to the next BD */
>  	*txbd_curr = (*txbd_curr + 1) % TX_BD_NUM;
> 

I wonder if this is correct. AFAIK a dma_wmb() only guarantees ordering of writes to DMA memory.
The assignment of the skb however is to RAM not to DMA.


Regards,
Lino
