From: "David Laight" <David.Laight@ACULAB.COM>
Subject: RE: [PATCH 2/3] ipv6, route: remove BACKTRACK() macro
Date: Mon, 10 Sep 2012 14:54:45 +0100
Message-ID: <AE90C24D6B3A694183C094C60CF0A2F6026B6FE6@saturn3.aculab.com>
References: <1347281326-26890-1-git-send-email-amwang@redhat.com> <1347281326-26890-2-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "David S. Miller" <davem@davemloft.net>
To: "Cong Wang" <amwang@redhat.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:58720 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1757068Ab2IJOF2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Sep 2012 10:05:28 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 01919-06 for <netdev@vger.kernel.org>;
 Mon, 10 Sep 2012 15:05:24 +0100 (BST)
Content-class: urn:content-classes:message
In-Reply-To: <1347281326-26890-2-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Subject: [PATCH 2/3] ipv6, route: remove BACKTRACK() macro
> 
> It doesn't save any code, nor it helps readability.
> 
> Signed-off-by: Cong Wang <amwang@redhat.com>
> ---
>  net/ipv6/route.c |   48 ++++++++++++++++++++++++++++--------------------
>  1 files changed, 28 insertions(+), 20 deletions(-)
> 
> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index b130bf2..71267e9 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -675,24 +675,6 @@ int rt6_route_rcv(struct net_device *dev, u8 *opt, int len,
>  }
>  #endif
> 
> -#define BACKTRACK(__net, saddr)			\
> -do { \
> -	if (rt == __net->ipv6.ip6_null_entry) {	\
> -		struct fib6_node *pn; \
> -		while (1) { \
> -			if (fn->fn_flags & RTN_TL_ROOT) \
> -				goto out; \
> -			pn = fn->parent; \
> -			if (FIB6_SUBTREE(pn) && FIB6_SUBTREE(pn) != fn) \
> -				fn = fib6_lookup(FIB6_SUBTREE(pn), NULL, saddr); \
> -			else \
> -				fn = pn; \
> -			if (fn->fn_flags & RTN_RTINFO) \
> -				goto restart; \
> -		} \
> -	} \
> -} while (0)
> -

It does, however, seem to avoid replicating some relatively complex logic.
OTOH goto out of a #define and hidden parameters (rt, fn ...) are not nice.

Maybe the 'while (1)' part can be an inline function?

	David
