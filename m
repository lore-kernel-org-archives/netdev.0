From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3] net: add Faraday FTMAC100 10/100 Ethernet driver
Date: Thu, 20 Jan 2011 16:35:46 +0100
Message-ID: <1295537746.2825.298.camel@edumazet-laptop>
References: <1295256060-2091-1-git-send-email-ratbert.chuang@gmail.com>
	 <1295537418-2057-1-git-send-email-ratbert.chuang@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	bhutchings@solarflare.com, joe@perches.com, dilinger@queued.net,
	Po-Yu Chuang <ratbert@faraday-tech.com>
To: Po-Yu Chuang <ratbert.chuang@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1295537418-2057-1-git-send-email-ratbert.chuang@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 20 janvier 2011 =C3=A0 23:30 +0800, Po-Yu Chuang a =C3=A9crit =
:

> +	/* push packet to protocol stack */
> +	netif_receive_skb(skb);
> +
> +	netdev->stats.rx_packets++;
> +	netdev->stats.rx_bytes +=3D skb->len;
> +
> +	(*processed)++;
> +
> +	return true;
> +}
> +

Hmm, after call to netif_receive_skb(skb), you are not allowed to acces=
s
skb anymore (maybe it was freed)

netdev->stats.rx_packets++;
netdev->stats.rx_bytes +=3D skb->len;
netif_receive_skb(skb);
