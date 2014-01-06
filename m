From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net-gre-gro: Add GRE support to the GRO stack
Date: Mon, 06 Jan 2014 15:43:30 -0500 (EST)
Message-ID: <20140106.154330.1324356005311602000.davem@davemloft.net>
References: <1388896679-23152-1-git-send-email-hkchu@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, herbert@gondor.apana.org.au,
	ogerlitz@mellanox.com, netdev@vger.kernel.org
To: hkchu@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34492 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755760AbaAFUnd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jan 2014 15:43:33 -0500
In-Reply-To: <1388896679-23152-1-git-send-email-hkchu@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "H.K. Jerry Chu" <hkchu@google.com>
Date: Sat,  4 Jan 2014 20:37:59 -0800

> This patch built on top of Commit 299603e8370a93dd5d8e8d800f0dff1ce2c53d36
> ("net-gro: Prepare GRO stack for the upcoming tunneling support") to add
> the support of the standard GRE (RFC1701/RFC2784/RFC2890) to the GRO
> stack. It also serves as an example for supporting other encapsulation
> protocols in the GRO stack in the future.
...

Applied, but you guys do realize:

> diff --git a/net/ipv4/Makefile b/net/ipv4/Makefile
> index 4b81e91..f8c49ce 100644
> --- a/net/ipv4/Makefile
> +++ b/net/ipv4/Makefile
> @@ -11,7 +11,7 @@ obj-y     := route.o inetpeer.o protocol.o \
>  	     tcp_offload.o datagram.o raw.o udp.o udplite.o \
>  	     udp_offload.o arp.o icmp.o devinet.o af_inet.o igmp.o \
>  	     fib_frontend.o fib_semantics.o fib_trie.o \
> -	     inet_fragment.o ping.o ip_tunnel_core.o
> +	     inet_fragment.o ping.o ip_tunnel_core.o gre_offload.o
>  
>  obj-$(CONFIG_NET_IP_TUNNEL) += ip_tunnel.o
>  obj-$(CONFIG_SYSCTL) += sysctl_net_ipv4.o
> @@ -19,7 +19,7 @@ obj-$(CONFIG_PROC_FS) += proc.o
>  obj-$(CONFIG_IP_MULTIPLE_TABLES) += fib_rules.o
>  obj-$(CONFIG_IP_MROUTE) += ipmr.o
>  obj-$(CONFIG_NET_IPIP) += ipip.o
> -gre-y := gre_demux.o gre_offload.o
> +gre-y := gre_demux.o
>  obj-$(CONFIG_NET_IPGRE_DEMUX) += gre.o
>  obj-$(CONFIG_NET_IPGRE) += ip_gre.o
>  obj-$(CONFIG_NET_IPVTI) += ip_vti.o

That the gre offload bits won't be registered unless GRE is enabled and
initialized/loaded, right?
