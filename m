From: Dave Young <dyoung@redhat.com>
Subject: Re: nf_reject_ipv4: module license 'unspecified' taints kernel
Date: Tue, 14 Oct 2014 16:11:09 +0800
Message-ID: <20141014081109.GA5357@dhcp-16-198.nay.redhat.com>
References: <20141010091904.GD1981@darkstar.nay.redhat.com>
 <20141010095520.GA3126@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57831 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755725AbaJNILV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Oct 2014 04:11:21 -0400
Content-Disposition: inline
In-Reply-To: <20141010095520.GA3126@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/10/14 at 11:56am, Pablo Neira Ayuso wrote:
> On Fri, Oct 10, 2014 at 05:19:04PM +0800, Dave Young wrote:
> > Hi,
> > 
> > With today's linus tree, I got below kmsg:
> > [   23.545204] nf_reject_ipv4: module license 'unspecified' taints kernel.
> > 
> > It could be caused by below commit:
> > 
> > commit c8d7b98bec43faaa6583c3135030be5eb4693acb
> > Author: Pablo Neira Ayuso <pablo@netfilter.org>
> > Date:   Fri Sep 26 14:35:15 2014 +0200
> > 
> >     netfilter: move nf_send_resetX() code to nf_reject_ipvX modules
> >     
> >     Move nf_send_reset() and nf_send_reset6() to nf_reject_ipv4 and
> >     nf_reject_ipv6 respectively. This code is shared by x_tables and
> >     nf_tables.
> >     
> >     Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
> 
> Patch attached, thanks for reporting.

Tested-by: Dave Young <dyoung@redhat.com>

> 
> P.S: Please, Cc netfilter-devel@vger.kernel.org in future reports, so
> we make sure things don't get lost.

Sure. Thanks.

> From d4358bcf64ba7a64d4de4e1dc5533c4c8f88ea82 Mon Sep 17 00:00:00 2001
> From: Pablo Neira Ayuso <pablo@netfilter.org>
> Date: Fri, 10 Oct 2014 11:25:20 +0200
> Subject: [PATCH] netfilter: missing module license in the nf_reject_ipvX
>  modules
> 
> [   23.545204] nf_reject_ipv4: module license 'unspecified' taints kernel.
> 
> Reported-by: Dave Young <dyoung@redhat.com>
> Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
> ---
>  net/ipv4/netfilter/nf_reject_ipv4.c |    3 +++
>  net/ipv6/netfilter/nf_reject_ipv6.c |    4 ++++
>  2 files changed, 7 insertions(+)
> 
> diff --git a/net/ipv4/netfilter/nf_reject_ipv4.c b/net/ipv4/netfilter/nf_reject_ipv4.c
> index b023b4e..92b303d 100644
> --- a/net/ipv4/netfilter/nf_reject_ipv4.c
> +++ b/net/ipv4/netfilter/nf_reject_ipv4.c
> @@ -6,6 +6,7 @@
>   * published by the Free Software Foundation.
>   */
>  
> +#include <linux/module.h>
>  #include <net/ip.h>
>  #include <net/tcp.h>
>  #include <net/route.h>
> @@ -125,3 +126,5 @@ void nf_send_reset(struct sk_buff *oldskb, int hook)
>  	kfree_skb(nskb);
>  }
>  EXPORT_SYMBOL_GPL(nf_send_reset);
> +
> +MODULE_LICENSE("GPL");
> diff --git a/net/ipv6/netfilter/nf_reject_ipv6.c b/net/ipv6/netfilter/nf_reject_ipv6.c
> index 5f5f043..20d9def 100644
> --- a/net/ipv6/netfilter/nf_reject_ipv6.c
> +++ b/net/ipv6/netfilter/nf_reject_ipv6.c
> @@ -5,6 +5,8 @@
>   * it under the terms of the GNU General Public License version 2 as
>   * published by the Free Software Foundation.
>   */
> +
> +#include <linux/module.h>
>  #include <net/ipv6.h>
>  #include <net/ip6_route.h>
>  #include <net/ip6_fib.h>
> @@ -161,3 +163,5 @@ void nf_send_reset6(struct net *net, struct sk_buff *oldskb, int hook)
>  		ip6_local_out(nskb);
>  }
>  EXPORT_SYMBOL_GPL(nf_send_reset6);
> +
> +MODULE_LICENSE("GPL");
> -- 
> 1.7.10.4
> 
