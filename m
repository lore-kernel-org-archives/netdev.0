From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: Increment OUTRSTS in tcp_send_active_reset()
Date: Wed, 04 Jun 2008 15:20:14 -0700 (PDT)
Message-ID: <20080604.152014.185732768.davem@davemloft.net>
References: <1212166947.12643.8.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sri@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38763
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754502AbYFDWUP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2008 18:20:15 -0400
In-Reply-To: <1212166947.12643.8.camel@w-sridhar2.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sridhar Samudrala <sri@us.ibm.com>
Date: Fri, 30 May 2008 10:02:27 -0700

> TCP "resets sent" counter is not incremented when a TCP Reset is 
> sent via tcp_send_active_reset().
> 
> Signed-off-by: Sridhar Samudrala <sri@us.ibm.com>
> 
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index e399bde..23c22d4 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -2131,6 +2131,8 @@ void tcp_send_active_reset(struct sock *sk, gfp_t priority)
>  	TCP_SKB_CB(skb)->when = tcp_time_stamp;
>  	if (tcp_transmit_skb(sk, skb, 0, priority))
>  		NET_INC_STATS(LINUX_MIB_TCPABORTFAILED);
> + 
> +	TCP_INC_STATS(TCP_MIB_OUTRSTS);
>  }
>  
>  /* WARNING: This routine must only be called when we have already sent

Patch applied.

That line before the new TCP_INC_STATS() adds trailing whitespace.
I fixed it up this time, but please have all of these details sorted
out before posting patches in the future, thank you.
