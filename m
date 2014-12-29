From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] net: stmmac: add BQL support
Date: Sun, 28 Dec 2014 23:48:14 -0800
Message-ID: <CAGVrzca_i9Wdpa9ecJYPZDgw+TqgMq1SH6ZmRnE4MoQ2dvnAAw@mail.gmail.com>
References: <1419778631-23067-1-git-send-email-b.galvani@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Beniamino Galvani <b.galvani@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1419778631-23067-1-git-send-email-b.galvani@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2014-12-28 6:57 GMT-08:00 Beniamino Galvani <b.galvani@gmail.com>:
> Add support for Byte Queue Limits to the STMicro MAC driver.
>
> Tested on a Amlogic S805 Cortex-A5 board, where the use of BQL
> slightly decreases the ping latency from ~10ms to ~3ms when the
> 100Mbps link is saturated by TCP streams. No difference is
> observed at 1Gbps.
>
> Signed-off-by: Beniamino Galvani <b.galvani@gmail.com>
> ---

[snip]

>         priv->dev->stats.tx_errors++;
> @@ -2049,6 +2057,7 @@ static netdev_tx_t stmmac_xmit(struct sk_buff *skb, struct net_device *dev)
>                 skb_tx_timestamp(skb);
>
>         priv->hw->dma->enable_dma_transmission(priv->ioaddr);
> +       netdev_sent_queue(dev, skb->len);

You are introducing a potential use after free here in case tx_lock is
eliminated one day and your TX reclaim logic kicks in and frees the
freshly transmitted SKB, it would be safer to just cache skb->len in a
local variable, and use it here.

>
>         spin_unlock(&priv->tx_lock);
>         return NETDEV_TX_OK;
-- 
Florian
