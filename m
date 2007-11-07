From: David Miller <davem@davemloft.net>
Subject: Re: [BUG] in inet6_create
Date: Wed, 07 Nov 2007 02:34:31 -0800 (PST)
Message-ID: <20071107.023431.52915555.davem@davemloft.net>
References: <472A3218.20708@tiscali.nl>
	<20071105.200046.69224507.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: 12o3l@tiscali.nl, netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52640
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751925AbXKGKec (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2007 05:34:32 -0500
In-Reply-To: <20071105.200046.69224507.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki / 吉藤英明 <yoshfuji@linux-ipv6.org>
Date: Mon, 05 Nov 2007 20:00:46 +0900 (JST)

> [IPV6]: Ensure to initialize inetsw6 array before we start accepting socket.
> 
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> 
> diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
> index ecbd388..9ecd41b 100644
> --- a/net/ipv6/af_inet6.c
> +++ b/net/ipv6/af_inet6.c
> @@ -789,6 +789,7 @@ static int __init inet6_init(void)
>  	/* Register the socket-side information for inet6_create.  */
>  	for(r = &inetsw6[0]; r < &inetsw6[SOCK_MAX]; ++r)
>  		INIT_LIST_HEAD(r);
> +	synchronize_net();
>  
>  	/* We MUST register RAW sockets before we create the ICMP6,
>  	 * IGMP6, or NDISC control sockets.
> 

I don't see how this can make a difference.

sock_register() takes spinlocks, and therefore provides
a full memory barrier.  The list initializations MUST
appear before any code path can see inet6_create() and
friends.

I simply cannot see how this crash is even possible.

Also, the original bug reporter cannot provide an inet6.o image that
matches any of his OOPS traces, so we cannot analyze this bug properly.
