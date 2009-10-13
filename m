From: David Miller <davem@davemloft.net>
Subject: Re: TCP_DEFER_ACCEPT is missing counter update
Date: Tue, 13 Oct 2009 00:11:06 -0700 (PDT)
Message-ID: <20091013.001106.226276168.davem@davemloft.net>
References: <20091013050705.GA2194@1wt.eu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: w@1wt.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58965
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933577AbZJMHLK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2009 03:11:10 -0400
In-Reply-To: <20091013050705.GA2194@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willy Tarreau <w@1wt.eu>
Date: Tue, 13 Oct 2009 07:07:06 +0200

> But in tcp_minisocks.c, this counter is only checked. And in
> fact, I have found no location which updates it. So I think
> that what was intended was to decrease it in tcp_minisocks
> whenever it is checked, which the trivial patch below does :
> 
> diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
> index f8d67cc..1b443b0 100644
> --- a/net/ipv4/tcp_minisocks.c
> +++ b/net/ipv4/tcp_minisocks.c
> @@ -645,6 +645,7 @@ struct sock *tcp_check_req(struct sock *sk, struct sk_buff *skb,
>  	if (inet_csk(sk)->icsk_accept_queue.rskq_defer_accept &&
>  	    TCP_SKB_CB(skb)->end_seq == tcp_rsk(req)->rcv_isn + 1) {
> +		inet_csk(sk)->icsk_accept_queue.rskq_defer_accept--;
>  		inet_rsk(req)->acked = 1;
>  		return NULL;
>  	}
>  
> Is there anything I am missing ?

Your logic looks sound and I can't come to any other conclusion
after going over this code, even going back to 2.4.x

Feel free to make a formal patch submission, thanks Willy.
