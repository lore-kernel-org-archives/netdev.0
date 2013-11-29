From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 02/17] net: Add utility function to set the rxhash
Date: Fri, 29 Nov 2013 15:42:28 -0500 (EST)
Message-ID: <20131129.154228.1595262198220391193.davem@davemloft.net>
References: <alpine.DEB.2.02.1311260913480.21024@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54412 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752606Ab3K2Umc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Nov 2013 15:42:32 -0500
In-Reply-To: <alpine.DEB.2.02.1311260913480.21024@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Tue, 26 Nov 2013 09:22:34 -0800 (PST)

> @@ -703,6 +703,20 @@ unsigned int skb_find_text(struct sk_buff *skb, unsigned int from,
>  			   unsigned int to, struct ts_config *config,
>  			   struct ts_state *state);
>  
> +enum rxhash_types {
> +	RXHASH_TYPE_NONE,	/* Undefined type */
> +	RXHASH_TYPE_L2,		/* Uses L2 information (addresses) */
> +	RXHASH_TYPE_L3,		/* Uses L3 information */
> +	RXHASH_TYPE_L4,		/* Uses L4 information (ports) */
> +};
> +
> +static inline void
> +skb_set_rxhash(struct sk_buff *skb, __u32 hash, enum rxhash_types type)
> +{
> +	skb->l4_rxhash = (type == RXHASH_TYPE_L4);
> +	skb->rxhash = hash;
> +}

This looks fine but I want slightly more documentation in the
comments.

First of all, L2 is link layer "addresses" like ethernet, and L3 is
for protocol "addresses" such as for IPv4/IPv6.  Make this explicit
in the comments.

Next, answer the question "Does RXHASH_TYPE_LN imply
RXHASH_TYPE_L{N-1}?"

I suspect it's variable, so for example L4 implies L3, but not
necessarily L2.  Document this fully.

Finally, are there any serious negative consequences for not setting
the type correctly?  Or is it just a minor performance issue?  Either
way, document it.

Thanks.
