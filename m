From: Mitchell Blank Jr <mitch@sfgoth.com>
Subject: Re: [PATCH] more const in skbuff
Date: Thu, 18 Sep 2003 13:42:53 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030918204253.GA43611@gaz.sfgoth.com>
References: <20030918102709.34211ee5.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20030918102709.34211ee5.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> -static inline int skb_cloned(struct sk_buff *skb)
> +static inline int skb_cloned(const struct sk_buff *skb)
>  {
>  	return skb->cloned && atomic_read(&skb_shinfo(skb)->dataref) != 1;
>  }

Are you sure that atomic_read() is garaunteed to take a const pointer?
My understanding is that an arch could in theory take a spinlock (although
none do currently)

If it is garaunteed to take a const pointer then please fix the inline in
include/asm-parisc/atomic.h or your patch will create a lot of warnings on
that architecture.

Other than that this patch is a strict subset of the "small skbuff.[ch]
tweaks" patch I posted here 2 weeks ago:
  http://oss.sgi.com/projects/netdev/archive/2003-09/msg00036.html
Never heard from davem one way or the other on that one.

-Mitch
