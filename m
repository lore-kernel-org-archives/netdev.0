From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ethernet: ti: netcp_core: return netdev_tx_t in
 xmit
Date: Fri, 10 Feb 2017 14:45:21 -0500 (EST)
Message-ID: <20170210.144521.1768411194584186345.davem@davemloft.net>
References: <1486650254-8976-1-git-send-email-ivan.khoronzhuk@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: w-kwok2@ti.com, m-karicheri2@ti.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: ivan.khoronzhuk@linaro.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1486650254-8976-1-git-send-email-ivan.khoronzhuk@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Date: Thu,  9 Feb 2017 16:24:14 +0200

> @@ -1300,7 +1301,7 @@ static int netcp_ndo_start_xmit(struct sk_buff *skb, struct net_device *ndev)
>  			dev_warn(netcp->ndev_dev, "padding failed (%d), packet dropped\n",
>  				 ret);
>  			tx_stats->tx_dropped++;
> -			return ret;
> +			return NETDEV_TX_BUSY;
>  		}
>  		skb->len = NETCP_MIN_PACKET_SIZE;
>  	}
> @@ -1329,7 +1330,7 @@ static int netcp_ndo_start_xmit(struct sk_buff *skb, struct net_device *ndev)
>  	if (desc)
>  		netcp_free_tx_desc_chain(netcp, desc, sizeof(*desc));
>  	dev_kfree_skb(skb);
> -	return ret;
> +	return NETDEV_TX_BUSY;
>  }

I really think these should be returning NET_XMIT_DROP.
