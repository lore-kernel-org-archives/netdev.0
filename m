From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] Fix incorrect prototype for ipxrtr_route_packet()
Date: Thu, 17 May 2007 15:27:46 -0700
Message-ID: <20070517152746.8bd3ea07.akpm@linux-foundation.org>
References: <1179398893.2859.479.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, acme@ghostprotocols.net,
	davem@davemloft.net, netdev@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:34794 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755807AbXEQWad (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 May 2007 18:30:33 -0400
In-Reply-To: <1179398893.2859.479.camel@shinybook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 17 May 2007 18:48:12 +0800
David Woodhouse <dwmw2@infradead.org> wrote:

> The function ipxrtr_route_packet() takes a 'len' argument of type
> size_t. However, its prototype in af_ipx.c incorrectly suggests that the
> corresponding argument is of type 'int' instead.
> 
> Discovered by building with --combine and letting the compiler see it
> all at once.
> 
> Signed-off-by: David Woodhouse <dwmw2@infradead.org>
> 
> --- a/net/ipx/af_ipx.c
> +++ b/net/ipx/af_ipx.c
> @@ -87,7 +87,7 @@ extern int ipxrtr_add_route(__be32 network, struct ipx_interface *intrfc,
>  			    unsigned char *node);
>  extern void ipxrtr_del_routes(struct ipx_interface *intrfc);
>  extern int ipxrtr_route_packet(struct sock *sk, struct sockaddr_ipx *usipx,
> -			       struct iovec *iov, int len, int noblock);
> +			       struct iovec *iov, size_t len, int noblock);
>  extern int ipxrtr_route_skb(struct sk_buff *skb);
>  extern struct ipx_route *ipxrtr_lookup(__be32 net);
>  extern int ipxrtr_ioctl(unsigned int cmd, void __user *arg);

Lovely.  So it was actually generating wrong code on all
sizeof(size_t)!=sizeof(int) architectures.

If only we could find some way in which all callers of a function as
well as its definition can see the same declaration?
