From: Brian Haley <brian.haley@hp.com>
Subject: Re: [GIT PATCH] IPv6 Updates for net-2.6.19
Date: Fri, 25 Aug 2006 15:29:25 -0400
Message-ID: <44EF4F95.7030305@hp.com>
References: <20060825.030034.68559899.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050404020904080708010504"
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:664 "EHLO atlrel6.hp.com")
	by vger.kernel.org with ESMTP id S1422791AbWHYT31 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2006 15:29:27 -0400
To: =?ISO-8859-1?Q?YOSHIFUJI_Hideaki_/_=3F=3F=3F=3F?=
	<yoshfuji@linux-ipv6.org>
In-Reply-To: <20060825.030034.68559899.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050404020904080708010504
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

> diff --git a/net/ipv6/route.c b/net/ipv6/route.c
> index c9f74c1..9b50e0c 100644
> --- a/net/ipv6/route.c
> +++ b/net/ipv6/route.c
> @@ -703,6 +703,7 @@ void ip6_route_input(struct sk_buff *skb
>  			.ip6_u = {
>  				.daddr = iph->daddr,
>  				.saddr = iph->saddr,
> +				.fwmark = skb->nfmark,
>  				.flowlabel = (* (u32 *) iph)&IPV6_FLOWINFO_MASK,
>  			},
>  		},

I can't build the latest 2.6.19-git with this patch, skb->nfmark 
requires CONFIG_NETFILTER, which isn't in my .config.  The obvious 
workaround is the patch below, but that might not be what you want.  Can 
send my .config if you need it.

-Brian


--------------050404020904080708010504
Content-Type: text/x-patch;
 name="nfmark.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="nfmark.patch"

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 9b50e0c..dc880cc 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -703,7 +703,9 @@ void ip6_route_input(struct sk_buff *skb
 			.ip6_u = {
 				.daddr = iph->daddr,
 				.saddr = iph->saddr,
+#ifdef CONFIG_NETFILTER
 				.fwmark = skb->nfmark,
+#endif
 				.flowlabel = (* (u32 *) iph)&IPV6_FLOWINFO_MASK,
 			},
 		},

--------------050404020904080708010504--
