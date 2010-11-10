From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] macvlan: lockless tx path
Date: Wed, 10 Nov 2010 09:39:20 -0800
Message-ID: <4CDAD8C8.20807@candelatech.com>
References: <1289403709.2860.216.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:55515 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754621Ab0KJRj3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Nov 2010 12:39:29 -0500
In-Reply-To: <1289403709.2860.216.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/10/2010 07:41 AM, Eric Dumazet wrote:
> macvlan is a stacked device, like tunnels. We should use the lockless
> mechanism we are using in tunnels and loopback.
>
> This patch completely removes locking in TX path.
>
> tx stat counters are added into existing percpu stat structure, renamed
> from rx_stats to pcpu_stats.
>
> Note : this reverts commit 2c11455321f37 (macvlan: add multiqueue
> capability)
>
> Signed-off-by: Eric Dumazet<eric.dumazet@gmail.com>
> ---
>   drivers/net/macvlan.c      |   72 +++++++++++++----------------------
>   include/linux/if_macvlan.h |   26 +++++++-----
>   2 files changed, 43 insertions(+), 55 deletions(-)
>

> diff --git a/include/linux/if_macvlan.h b/include/linux/if_macvlan.h
> index 8a2fd66..3779b5f 100644
> --- a/include/linux/if_macvlan.h
> +++ b/include/linux/if_macvlan.h
> @@ -25,19 +25,23 @@ struct macvlan_port;
>   struct macvtap_queue;
>
>   /**
> - *	struct macvlan_rx_stats - MACVLAN percpu rx stats
> + *	struct macvlan_pcpu_stats - MACVLAN percpu stats
>    *	@rx_packets: number of received packets
>    *	@rx_bytes: number of received bytes
>    *	@rx_multicast: number of received multicast packets
> + *	@tx_

Minor nit..seems you missed a few there?

>    *	@syncp: synchronization point for 64bit counters
>    *	@rx_errors: number of errors
>    */
> -struct macvlan_rx_stats {
> +struct macvlan_pcpu_stats {
>   	u64			rx_packets;
>   	u64			rx_bytes;
>   	u64			rx_multicast;
> +	u64			tx_packets;
> +	u64			tx_bytes;
>   	struct u64_stats_sync	syncp;
>   	unsigned long		rx_errors;
> +	unsigned long		tx_dropped;

Any reason to not also make those u64?


Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

