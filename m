From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH] NETLINK: Use SKB_MAXORDER to calculate NLMSG_GOODSIZE
Date: Sat, 29 Jan 2005 01:27:01 +0100
Message-ID: <20050129002701.GY31837@postel.suug.ch>
References: <20050128230327.GV31837@postel.suug.ch> <E1CufRB-0000zf-00@gondolin.me.apana.org.au> <20050128234828.GA24868@yakov.inr.ac.ru> <20050129002128.GX31837@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>, davem@davemloft.net,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Content-Disposition: inline
In-Reply-To: <20050129002128.GX31837@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Thomas Graf <20050129002128.GX31837@postel.suug.ch> 2005-01-29 01:21
> --- linux-2.6.11-rc2-bk4.orig/net/ipv4/tcp_input.c	2005-01-26 18:19:42.000000000 +0100
> +++ linux-2.6.11-rc2-bk4/net/ipv4/tcp_input.c	2005-01-29 01:12:30.000000000 +0100
> @@ -3760,8 +3760,7 @@
>  	while (before(start, end)) {
>  		struct sk_buff *nskb;
>  		int header = skb_headroom(skb);
> -		int copy = (PAGE_SIZE - sizeof(struct sk_buff) -
> -			    sizeof(struct skb_shared_info) - header - 31)&~15;
> +		int copy = SKB_MAX_ORDER(header + 31, 0);
>  
>  		/* Too big header? This can happen with IPv6. */
>  		if (copy < 0)

Sorry, this is incomplete, we should refetch copy via (skb->end - skb->head) after
allocating it.  I have to think some more about this first. ;-)
