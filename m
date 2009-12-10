From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH] netfilter: Fix compiler warning.
Date: Thu, 10 Dec 2009 23:06:32 +0100 (CET)
Message-ID: <alpine.LSU.2.01.0912102301380.5189@obet.zrqbmnf.qr>
References: <pvmein2bj1p.fsf@chavey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, eric.dumazet@gmail.com,
	akpm@google.com
To: chavey@google.com
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <pvmein2bj1p.fsf@chavey.mtv.corp.google.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Donnerstag 2009-12-10 22:44, chavey@google.com wrote:

>Fix compiler warning "discards qualifiers from pointer target type",
>by allowing explicit discard of const qualifier thru type casting.
>The const_cast() macro is taken from a patch from Kaveh R. Ghazi

Uhm, I am not getting any warning on xt_time with either gcc-4.4.1
or gcc-4.5_20091126, so what case are we actually trying to fix?

>--- a/net/netfilter/xt_time.c
>+++ b/net/netfilter/xt_time.c
>@@ -170,7 +170,7 @@ time_mt(const struct sk_buff *skb, const struct xt_match_param *par)
> 	 * it arrived at the right moment before 13:00.
> 	 */
> 	if (skb->tstamp.tv64 == 0)
>-		__net_timestamp((struct sk_buff *)skb);
>+		__net_timestamp((struct sk_buff *)const_cast(skb));
> 
> 	stamp = ktime_to_ns(skb->tstamp);
> 	stamp = div_s64(stamp, NSEC_PER_SEC);
