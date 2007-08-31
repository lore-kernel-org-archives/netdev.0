From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] make _minimum_ TCP retransmission timeout configurable
 take 2
Date: Fri, 31 Aug 2007 15:20:52 -0700
Message-ID: <46D89444.3080508@hp.com>
References: <46D859D9.6030407@hp.com>	<20070831.115706.97292718.davem@davemloft.net>	<46D88146.9090401@hp.com> <20070831.143855.88699905.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel12.hp.com ([156.153.255.237]:38436 "EHLO palrel12.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759425AbXHaWVU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Aug 2007 18:21:20 -0400
In-Reply-To: <20070831.143855.88699905.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Rick Jones <rick.jones2@hp.com>
> Date: Fri, 31 Aug 2007 13:59:50 -0700
> 
> 
>>ip is at tcp_rto_min+0x20/0x40
> 
> 
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index 1ee7212..bbad2cd 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -560,7 +560,7 @@ static u32 tcp_rto_min(struct sock *sk)
>  	struct dst_entry *dst = __sk_dst_get(sk);
>  	u32 rto_min = TCP_RTO_MIN;
>  
> -	if (dst_metric_locked(dst, RTAX_RTO_MIN))
> +	if (dst && dst_metric_locked(dst, RTAX_RTO_MIN))
>  		rto_min = dst->metrics[RTAX_RTO_MIN-1];
>  	return rto_min;
>  }

Applied and beating on it with a while loop doing a bunch of ip route 
del add change stuff while netperf TCP_CRR tests are running.  Thusfar 
things seem OK wrt the system staying alive, but since I only saw the 
failure once I'm not sure how much that is really saying.

I'm going to go ahead and take a look at input vs output units and 
differences between those with rto_min vs rtt.

rick jones
