From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] net: add Faraday FTMAC100 10/100 Ethernet driver
Date: Mon, 17 Jan 2011 19:21:02 +0100
Message-ID: <1295288462.3335.55.camel@edumazet-laptop>
References: <1294919372-1904-1-git-send-email-ratbert.chuang@gmail.com>
	 <1295256060-2091-1-git-send-email-ratbert.chuang@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ratbert@faraday-tech.com, bhutchings@solarflare.com,
	joe@perches.com, dilinger@queued.net
To: Po-Yu Chuang <ratbert.chuang@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1295256060-2091-1-git-send-email-ratbert.chuang@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le lundi 17 janvier 2011 =C3=A0 17:21 +0800, Po-Yu Chuang a =C3=A9crit =
:


> +
> +	spin_lock_irqsave(&priv->tx_lock, flags);
> +	ftmac100_txdes_set_skb(txdes, skb);
> +	ftmac100_txdes_set_dma_addr(txdes, map);
> +
> +	ftmac100_txdes_set_first_segment(txdes);
> +	ftmac100_txdes_set_last_segment(txdes);
> +	ftmac100_txdes_set_txint(txdes);
> +	ftmac100_txdes_set_buffer_size(txdes, len);
> +

I wonder if its not too expensive to read/modify/write txdes->txdes1

Maybe you should use a temporary u32 var and perform one final write on
txdes->txdes1 (with the set_dma_own)

> +	priv->tx_pending++;
> +	if (priv->tx_pending =3D=3D TX_QUEUE_ENTRIES) {
> +		if (net_ratelimit())
> +			netdev_info(netdev, "tx queue full\n");
> +
> +		netif_stop_queue(netdev);
> +	}
> +
> +	/* start transmit */
> +	ftmac100_txdes_set_dma_own(txdes);

	txdes->txdes1 =3D txdes1;

BTW, shouldnt you use cpu_to_be32() or cpu_to_le32(), if this driver is
multi platform ?
