From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH] ip6tables: use skb->len for accounting
Date: Fri, 23 Jul 2010 08:16:51 +0200 (CEST)
Message-ID: <alpine.LSU.2.01.1007230813300.815@obet.zrqbmnf.qr>
References: <1279855877-8945-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1279855877-8945-1-git-send-email-xiaosuo@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Friday 2010-07-23 05:31, Changli Gao wrote:

>ip6tables: use skb->len for accounting
>
>ipv6_hdr(skb)->payload_len is ZERO and can't be used for accounting, if the
>payload is a Jumbo Payload specified in RFC2675.
>
>Signed-off-by: Changli Gao <xiaosuo@gmail.com>
>----
> net/ipv6/netfilter/ip6_tables.c |    4 +---
> 1 file changed, 1 insertion(+), 3 deletions(-)
>diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
>index dc41d6d..33113c1 100644
>--- a/net/ipv6/netfilter/ip6_tables.c
>+++ b/net/ipv6/netfilter/ip6_tables.c
>@@ -387,9 +387,7 @@ ip6t_do_table(struct sk_buff *skb,
> 				goto no_match;
> 		}
> 
>-		ADD_COUNTER(e->counters,
>-			    ntohs(ipv6_hdr(skb)->payload_len) +
>-			    sizeof(struct ipv6hdr), 1);
>+		ADD_COUNTER(e->counters, skb->len, 1);
> 
> 		t = ip6t_get_target_c(e);
> 		IP_NF_ASSERT(t->u.kernel.target);
>--

I wonder how this fares with trailing padding or data, like, when
you have a standard v4/v6 packet created in a raw socket, and append
a bunch of \0s to it.

