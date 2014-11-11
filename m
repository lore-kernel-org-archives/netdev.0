From: Edward Cree <ecree@solarflare.com>
Subject: Re: [Patch net-next] net: remove netif_set_real_num_rx_queues()
Date: Tue, 11 Nov 2014 13:10:24 +0000
Message-ID: <54620AC0.9080509@solarflare.com>
References: <1415648136-4167-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:26365 "EHLO
	nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750799AbaKKNKd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2014 08:10:33 -0500
In-Reply-To: <1415648136-4167-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/11/14 19:35, Cong Wang wrote:
> vlan was the only user of netif_set_real_num_rx_queues(),
> but it no longer calls it after
> commit 4af429d29b341bb1735f04c2fb960178 ("vlan: lockless transmit path").
> So we can just remove it.
>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
>
> ---
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index 888d551..4a6f770 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -2762,23 +2762,6 @@ static inline int netif_set_real_num_rx_queues(struct net_device *dev,
>  }
>  #endif
>  
> -static inline int netif_copy_real_num_queues(struct net_device *to_dev,
> -					     const struct net_device *from_dev)
Patch title says you're removing _set_ but body only removes _copy_. 
Which one is right?
> -{
> -	int err;
> -
> -	err = netif_set_real_num_tx_queues(to_dev,
> -					   from_dev->real_num_tx_queues);
> -	if (err)
> -		return err;
> -#ifdef CONFIG_SYSFS
> -	return netif_set_real_num_rx_queues(to_dev,
> -					    from_dev->real_num_rx_queues);
> -#else
> -	return 0;
> -#endif
> -}
> -
>  #ifdef CONFIG_SYSFS
>  static inline unsigned int get_netdev_rx_queue_index(
>  		struct netdev_rx_queue *queue)
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
