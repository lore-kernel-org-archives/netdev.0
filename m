From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] NETLINK: Use SKB_MAXORDER to calculate NLMSG_GOODSIZE
Date: Sat, 29 Jan 2005 10:22:01 +1100
Message-ID: <E1CufRB-0000zf-00@gondolin.me.apana.org.au>
References: <20050128230327.GV31837@postel.suug.ch>
Cc: davem@davemloft.net, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: tgraf@suug.ch (Thomas Graf)
In-Reply-To: <20050128230327.GV31837@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Thomas Graf <tgraf@suug.ch> wrote:
> 
> The current value doesn't make much sense anymore because
> skb_shared_info isn't taken into account which means that
> depending on the architecture NLMSG_GOOSIZE can exceed PAGE_SIZE
> resulting in a waste of almost a complete page.

You're quite right.

> Using SKB_MAXORDER solves this potential leak at the cost of
> slightly smaller but safer sizes for some architectures.

At first glance it's not clear which of sk_buff or skb_shared_info
is bigger.  So it might even end up being bigger :)

> -#define NLMSG_GOODSIZE (PAGE_SIZE - ((sizeof(struct sk_buff)+0xF)&~0xF))
> +#define NLMSG_GOODORDER 0
> +#define NLMSG_GOODSIZE (SKB_MAX_ORDER(0, NLMSG_GOODORDER))

Are we ever going use NLMSG_GOODORDER for anything? If not why don't
we go straight to NLMSG_GOODSIZE?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
