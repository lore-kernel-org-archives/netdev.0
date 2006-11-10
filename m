From: Paul Moore <paul.moore@hp.com>
Subject: Re: [NETLINK]: Do precise netlink message allocations where possible
Date: Fri, 10 Nov 2006 11:04:14 -0500
Message-ID: <4554A2FE.2020405@hp.com>
References: <20061110121706.GH8693@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel8.hp.com ([156.153.255.206]:28315 "EHLO atlrel8.hp.com")
	by vger.kernel.org with ESMTP id S1946722AbWKJQEQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Nov 2006 11:04:16 -0500
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20061110121706.GH8693@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thomas Graf wrote:
> Account for the netlink message header size directly in nlmsg_new()
> instead of relying on the caller calculate it correctly.
> 
> Replaces error handling of message construction functions when
> constructing notifications with bug traps since a failure implies
> a bug in calculating the size of the skb.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>
> 
> Index: net-2.6.20/include/net/netlink.h
> ===================================================================
> --- net-2.6.20.orig/include/net/netlink.h	2006-11-08 15:29:26.000000000 +0100
> +++ net-2.6.20/include/net/netlink.h	2006-11-10 11:18:34.000000000 +0100
> @@ -500,14 +500,15 @@
>  
>  /**
>   * nlmsg_new - Allocate a new netlink message
> - * @size: maximum size of message
> + * @payload: size of the message payload
>   * @flags: the type of memory to allocate.
>   *
> - * Use NLMSG_GOODSIZE if size isn't know and you need a good default size.
> + * Use NLMSG_DEFAULT_SIZE if the size of the payload isn't known
> + * and a good default is needed.
>   */
> -static inline struct sk_buff *nlmsg_new(int size, gfp_t flags)
> +static inline struct sk_buff *nlmsg_new(size_t payload, gfp_t flags)
>  {
> -	return alloc_skb(size, flags);
> +	return alloc_skb(nlmsg_total_size(payload), flags);
>  }

I like this approach, it makes much more sense to me then the previous
implementation which was a simple "alias" to alloc_skb().  Also, the NetLabel
relevant sections look fine to me.

Acked-by: Paul Moore <paul.moore@hp.com>

-- 
paul moore
linux security @ hp
