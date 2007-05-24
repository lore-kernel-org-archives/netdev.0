From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 10/12] drivers: PMC MSP71xx ethernet driver
Date: Thu, 24 May 2007 17:46:05 -0400
Message-ID: <4656079D.6010109@garzik.org>
References: <200705101839.l4AIdHB9030885@pasqua.pmc-sierra.bc.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, linux-mips@linux-mips.org,
	netdev@vger.kernel.org
To: Marc St-Jean <stjeanma@pmc-sierra.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:48371 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750955AbXEXVq4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 May 2007 17:46:56 -0400
In-Reply-To: <200705101839.l4AIdHB9030885@pasqua.pmc-sierra.bc.ca>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Marc St-Jean wrote:
> +inline static void
> +mspeth_skb_headerinit(struct sk_buff *skb)
> +{
> +	/* these are essential before init */
> +	dst_release(skb->dst);
> +#ifdef CONFIG_XFRM
> +	secpath_put(skb->sp);
> +#endif
> +#ifdef CONFIG_NETFILTER
> +	nf_conntrack_put(skb->nfct);
> +#if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
> +	nf_conntrack_put_reasm(skb->nfct_reasm);
> +#endif
> +#ifdef CONFIG_BRIDGE_NETFILTER
> +	nf_bridge_put(skb->nf_bridge);
> +#endif
> +#endif /* CONFIG_NETFILTER */
> +
> +	/*
> +	 * Now initialise the skb...
> +	 * Clear the members till skb->truesize.
> +	 */
> +	memset(skb, 0, offsetof(struct sk_buff, truesize));
> +}
> +#endif /* CONFIG_MSPETH_SKB_RECYCLE */

Did you ever resend this driver addition, with the above unmaintainable 
skb init hacks removed?

	Jeff


