From: Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Subject: Re: Patch: add loglevel to printk's in net/ipv4/route.c
Date: Wed, 29 Dec 2004 00:02:53 -0200
Message-ID: <41D2104D.3010406@conectiva.com.br>
References: <Pine.LNX.4.61.0412290256000.3528@dragon.hygekrogen.localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Networking Team <netdev@oss.sgi.com>,
	linux-net <linux-net@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	linux-kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-net-owner@vger.kernel.org>
To: Jesper Juhl <juhl-lkml@dif.dk>
In-Reply-To: <Pine.LNX.4.61.0412290256000.3528@dragon.hygekrogen.localhost>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jesper Juhl wrote:
> Small patch below adds loglevels to a few printk's in net/ipv4/route.c
> 
> 
> Signed-off-by: Jesper Juhl <juhl-lkml@dif.dk>
> 
> diff -up linux-2.6.10-orig/net/ipv4/route.c linux-2.6.10/net/ipv4/route.c
> --- linux-2.6.10-orig/net/ipv4/route.c	2004-12-24 22:35:40.000000000 +0100
> +++ linux-2.6.10/net/ipv4/route.c	2004-12-29 02:55:03.000000000 +0100
> @@ -889,8 +889,8 @@ restart:
>  		printk(KERN_DEBUG "rt_cache @%02x: %u.%u.%u.%u", hash,
>  		       NIPQUAD(rt->rt_dst));
>  		for (trt = rt->u.rt_next; trt; trt = trt->u.rt_next)
> -			printk(" . %u.%u.%u.%u", NIPQUAD(trt->rt_dst));
> -		printk("\n");
> +			printk(KERN_DEBUG " . %u.%u.%u.%u", NIPQUAD(trt->rt_dst));
> +		printk(KERN_DEBUG "\n");
>  	}
>  #endif
>  	rt_hash_table[hash].chain = rt;
> @@ -1802,11 +1802,11 @@ martian_source:
>  			unsigned char *p = skb->mac.raw;
>  			printk(KERN_WARNING "ll header: ");
>  			for (i = 0; i < dev->hard_header_len; i++, p++) {
> -				printk("%02x", *p);
> +				printk(KERN_WARNING "%02x", *p);
>  				if (i < (dev->hard_header_len - 1))
>  					printk(":");
>  			}
> -			printk("\n");
> +			printk(KERN_WARNING "\n");


Are you sure the output is much improved? ;)

- Arnaldo
