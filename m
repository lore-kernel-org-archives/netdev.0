From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next repost] MPLS: Use mpls_features to activate
 software MPLS GSO segmentation
Date: Fri, 30 May 2014 15:43:18 -0700 (PDT)
Message-ID: <20140530.154318.305349726927694948.davem@davemloft.net>
References: <20140530053519.GA3444@verge.net.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jesse@nicira.com, tgraf@suug.ch,
	dev@openvswitch.org
To: horms@verge.net.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60097 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755432AbaE3WnT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 May 2014 18:43:19 -0400
In-Reply-To: <20140530053519.GA3444@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <horms@verge.net.au>
Date: Fri, 30 May 2014 14:35:19 +0900

> If an MPLS packet requires segmentation then use mpls_features
> to determine if the software implementation should be used.
> 
> As no driver advertises MPLS GSO segmentation this will always be
> the case.
> 
> I had not noticed that this was necessary before as software MPLS GSO
> segmentation was already being used in my test environment. I believe that
> the reason for that is the skbs in question always had fragments and the
> driver I used does not advertise NETIF_F_FRAGLIST (which seems to be the
> case for most drivers). Thus software segmentation was activated by
> skb_gso_ok().
> 
> Thanks to Jesse Gross for prompting me to investigate this.
> 
> Acked-by: Jesse Gross <jesse@nicira.com>
> Signed-off-by: Simon Horman <horms@verge.net.au>

Just requesting some stylistic changes:

> +/* If MPLS offload request, verify we are testing hardware MPLS features
> + * instead of standard features for the netdev.
> + */
> +#ifdef CONFIG_NET_MPLS_GSO
> +static inline netdev_features_t net_mpls_features(struct sk_buff *skb,
> +	struct net_device *dev, netdev_features_t features)

Do not use inline in a foo.c file, let the compiler make the decision.

Also, line up the arguments on the second line correctly, they should
start exactly at the first column after the openning parenthesis of
the previous line.

> +static inline netdev_features_t net_mpls_features(struct sk_buff *skb,
> +	struct net_device *dev, netdev_features_t features)
> +{
> +	return features;
> +}

Similarly.
