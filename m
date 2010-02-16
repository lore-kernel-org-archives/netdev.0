From: Joe Perches <joe@perches.com>
Subject: Re: IPv6 20/62: reassembly: replace magic number with macro
 definitions
Date: Tue, 16 Feb 2010 07:43:38 -0800
Message-ID: <1266335018.29987.50.camel@Joe-Laptop.home>
References: <20100216145517.2796.40634.sendpatchset@x2.localnet>
	 <20100216145545.2796.47717.sendpatchset@x2.localnet>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>,
	Shan Wei <shanwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1111 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932451Ab0BPPnk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Feb 2010 10:43:40 -0500
In-Reply-To: <20100216145545.2796.47717.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-02-16 at 15:55 +0100, Patrick McHardy wrote:
> commit 7c070aa947d1a4105742378579c267f6e7fd08a1
> Author: Shan Wei <shanwei@cn.fujitsu.com>
> Date:   Wed Jan 20 10:42:41 2010 +0100
> 
>     IPv6: reassembly: replace magic number with macro definitions
>     
>     Use macro to define high/low thresh value, refer to IPV6_FRAG_TIMEOUT.
>     
>     Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
>     Acked-by: David S. Miller <davem@davemloft.net>
>     Signed-off-by: Patrick McHardy <kaber@trash.net>
> 
> diff --git a/include/net/ipv6.h b/include/net/ipv6.h
> index ccab594..299bbf5 100644
> --- a/include/net/ipv6.h
> +++ b/include/net/ipv6.h
> @@ -246,6 +246,8 @@ extern int ipv6_opt_accepted(struct sock *sk, struct sk_buff *skb);
>  int ip6_frag_nqueues(struct net *net);
>  int ip6_frag_mem(struct net *net);
>  
> +#define IPV6_FRAG_HIGH_THRESH	262144		/* == 256*1024 */
> +#define IPV6_FRAG_LOW_THRESH	196608		/* == 192*1024 */
>  #define IPV6_FRAG_TIMEOUT	(60*HZ)		/* 60 seconds */

196608 isn't a number I want to remember.
Is this better as:

#define IPV6_FRAG_HIGH_THRESH	(256 * 1024)	/* 262144 */
#define IPV6_FRAG_LOW_THRESH	(192 * 1024)	/* 196608 */


