From: Jan Ceuleers <jan.ceuleers@computer.org>
Subject: Re: [PATCH v5 6/6 resend] net: sh_eth: use NAPI
Date: Sat, 02 Jun 2012 12:05:32 +0200
Message-ID: <4FC9E56C.4000707@computer.org>
References: <4FC48589.6060009@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	SH-Linux <linux-sh@vger.kernel.org>
To: "Shimoda, Yoshihiro" <yoshihiro.shimoda.uh@renesas.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay010.isp.belgacom.be ([195.238.6.177]:19510 "EHLO
	mailrelay010.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933439Ab2FBKJ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jun 2012 06:09:56 -0400
In-Reply-To: <4FC48589.6060009@renesas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/29/2012 10:15 AM, Shimoda, Yoshihiro wrote:
> @@ -1087,13 +1088,17 @@ static int sh_eth_rx(struct net_device *ndev)
>  				skb_reserve(skb, NET_IP_ALIGN);
>  			skb_put(skb, pkt_len);
>  			skb->protocol = eth_type_trans(skb, ndev);
> -			netif_rx(skb);
> -			ndev->stats.rx_packets++;
> -			ndev->stats.rx_bytes += pkt_len;
> +			if (netif_receive_skb(skb) == NET_RX_DROP) {
> +				ndev->stats.rx_dropped++;
> +			} else {
> +				ndev->stats.rx_packets++;
> +				ndev->stats.rx_bytes += pkt_len;
> +			}
>  		}
>  		rxdesc->status |= cpu_to_edmac(mdp, RD_RACT);
>  		entry = (++mdp->cur_rx) % mdp->num_rx_ring;
>  		rxdesc = &mdp->rx_ring[entry];
> +		(*work)++;
>  	}
> 
>  	/* Refill the Rx ring buffers. */

Please forgive a newbie's question/comment; feel free to ignore if I'm
wasting your time. Particularly because it's about an aspect of the
driver that you're not changing in this patch. (And yes, I know that
you've been asked to sit on this patch series until net-next opens up
again).

I see that most users of netif_receive_skb() ignore its return value.
Some drivers (including this-one) do check it and use it to determine
whether counters should be updated. But looking at netif_receive_skb()
itself I see that there's counter infrastructure there already.

So why this in-driver set of counters, I wonder?

Thanks, Jan
