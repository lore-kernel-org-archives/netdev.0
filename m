From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: [PATCH] 2.6.0-bk6 net/core/dev.c
Date: Wed, 24 Sep 2003 10:13:53 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0309241012110.3178-100000@home.osdl.org>
References: <1064416289.1804.3.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Kernel Mailing List <linux-kernel@vger.kernel.org>, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Joe Perches <joe@perches.com>, "David S. Miller" <davem@redhat.com>
In-Reply-To: <1064416289.1804.3.camel@localhost.localdomain>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


On Wed, 24 Sep 2003, Joe Perches wrote:
>
> Symmetric to dev_add_pack.

Looks sane, but wouldn't it be cleaner to put this ugly special case logic
with casts etc in an inline function and make the code a bit more readable
at the same time?

David?

		Linus

> diff -urN linux-2.6.0-test5/net/core/dev.c shared_skb/net/core/dev.c
> --- linux-2.6.0-test5/net/core/dev.c	2003-09-22 08:04:06.000000000 -0700
> +++ shared_skb/net/core/dev.c	2003-09-22 14:02:08.000000000 -0700
> @@ -281,7 +281,7 @@
>  	list_for_each_entry(pt1, head, list) {
>  		if (pt == pt1) {
>  #ifdef CONFIG_NET_FASTROUTE
> -			if (pt->data)
> +			if (pt->data && (long)pt->data != 1)
>  				netdev_fastroute_obstacles--;
>  #endif
>  			list_del_rcu(&pt->list);
> 
