From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v4] net: add Faraday FTMAC100 10/100 Ethernet driver
Date: Fri, 21 Jan 2011 10:08:07 +0100
Message-ID: <1295600887.2601.5.camel@edumazet-laptop>
References: <1295537418-2057-1-git-send-email-ratbert.chuang@gmail.com>
	 <1295596533-1748-1-git-send-email-ratbert.chuang@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	bhutchings@solarflare.com, joe@perches.com, dilinger@queued.net,
	mirqus@gmail.com, Po-Yu Chuang <ratbert@faraday-tech.com>
To: Po-Yu Chuang <ratbert.chuang@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1295596533-1748-1-git-send-email-ratbert.chuang@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 21 janvier 2011 =C3=A0 15:55 +0800, Po-Yu Chuang a =C3=A9cr=
it :
> From: Po-Yu Chuang <ratbert@faraday-tech.com>
>=20
> FTMAC100 Ethernet Media Access Controller supports 10/100 Mbps and
> MII.  This driver has been working on some ARM/NDS32 SoC's including
> Faraday A320 and Andes AG101.
>=20
> Signed-off-by: Po-Yu Chuang <ratbert@faraday-tech.com>


> +
> +static bool ftmac100_tx_complete_packet(struct ftmac100 *priv)
> +{
=2E..
> +
> +	dma_unmap_single(priv->dev, map, skb_headlen(skb), DMA_TO_DEVICE);
> +
> +	dev_kfree_skb_irq(skb);
> +
> +	ftmac100_txdes_reset(txdes);
> +
> +	ftmac100_tx_clean_pointer_advance(priv);
> +
> +	priv->tx_pending--;
> +	netif_wake_queue(netdev);
> +
> +	return true;
> +}
> +

Thanks to NAPI, you can free skb directly, not queuing it via
NET_TX_SOFTIRQ softirq, using dev_kfree_skb() instead of
dev_kfree_skb_irq()
