From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v4] add stealth mode
Date: Wed, 16 Sep 2015 04:11:22 -0700
Message-ID: <1442401882.4116.52.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20150915.120057.1457031142615117336.davem@davemloft.net>
	 <1442397259-28894-1-git-send-email-matteo@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Matteo Croce <matteo@openwrt.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1442397259-28894-1-git-send-email-matteo@openwrt.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2015-09-16 at 11:54 +0200, Matteo Croce wrote:
> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
> index 93898e0..fe62ae0 100644
> --- a/net/ipv4/tcp_ipv4.c
> +++ b/net/ipv4/tcp_ipv4.c
> @@ -77,6 +77,7 @@
>  #include <net/busy_poll.h>
>  
>  #include <linux/inet.h>
> +#include <linux/inetdevice.h>
>  #include <linux/ipv6.h>
>  #include <linux/stddef.h>
>  #include <linux/proc_fs.h>
> @@ -1652,7 +1653,7 @@ csum_error:
>  		TCP_INC_STATS_BH(net, TCP_MIB_CSUMERRORS);
>  bad_packet:
>  		TCP_INC_STATS_BH(net, TCP_MIB_INERRS);
> -	} else {
> +	} else if (!IN_DEV_STEALTH(skb->dev->ip_ptr)) {
>  		tcp_v4_send_reset(NULL, skb);
>  	}


It is illegal to deref skb->dev->ip_ptr without proper accessor /
annotations.

Check 

struct in_device *in_dev = __in_dev_get_rcu(skb->dev); 

(Same remarks in other places of your patch)
