From: "Shimoda, Yoshihiro" <yoshihiro.shimoda.uh@renesas.com>
Subject: Re: [PATCH v5 6/6 resend] net: sh_eth: use NAPI
Date: Mon, 04 Jun 2012 20:17:22 +0900
Message-ID: <4FCC9942.5080809@renesas.com>
References: <4FC48589.6060009@renesas.com> <4FC9E56C.4000707@computer.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	SH-Linux <linux-sh@vger.kernel.org>
To: Jan Ceuleers <jan.ceuleers@computer.org>
Return-path: <linux-sh-owner@vger.kernel.org>
In-reply-to: <4FC9E56C.4000707@computer.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2012/06/02 19:05, Jan Ceuleers wrote:
> On 05/29/2012 10:15 AM, Shimoda, Yoshihiro wrote:
>> @@ -1087,13 +1088,17 @@ static int sh_eth_rx(struct net_device *ndev)
>>  				skb_reserve(skb, NET_IP_ALIGN);
>>  			skb_put(skb, pkt_len);
>>  			skb->protocol = eth_type_trans(skb, ndev);
>> -			netif_rx(skb);
>> -			ndev->stats.rx_packets++;
>> -			ndev->stats.rx_bytes += pkt_len;
>> +			if (netif_receive_skb(skb) == NET_RX_DROP) {
>> +				ndev->stats.rx_dropped++;
>> +			} else {
>> +				ndev->stats.rx_packets++;
>> +				ndev->stats.rx_bytes += pkt_len;
>> +			}
>>  		}
>>  		rxdesc->status |= cpu_to_edmac(mdp, RD_RACT);
>>  		entry = (++mdp->cur_rx) % mdp->num_rx_ring;
>>  		rxdesc = &mdp->rx_ring[entry];
>> +		(*work)++;
>>  	}
>>
>>  	/* Refill the Rx ring buffers. */
> 
> Please forgive a newbie's question/comment; feel free to ignore if I'm
> wasting your time. Particularly because it's about an aspect of the
> driver that you're not changing in this patch. (And yes, I know that
> you've been asked to sit on this patch series until net-next opens up
> again).
> 
> I see that most users of netif_receive_skb() ignore its return value.
> Some drivers (including this-one) do check it and use it to determine
> whether counters should be updated. But looking at netif_receive_skb()
> itself I see that there's counter infrastructure there already.
> 
> So why this in-driver set of counters, I wonder?

Thank you for the comment.
I also think that the driver should not update the rx_dropped counter
when netif_receive_skb() returns NET_RX_DROP. I will fix this.

Best regards,
Yoshihiro Shimoda
