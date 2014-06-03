From: yamamoto@valinux.co.jp (YAMAMOTO Takashi)
Subject: Re: [ovs-dev] [PATCH v4 net-next] MPLS: Use mpls_features to
 activate software MPLS GSO segmentation
Date: Tue,  3 Jun 2014 13:46:11 +0900 (JST)
Message-ID: <20140603044611.C2B0970BA7@kuma.localdomain>
References: <20140603043047.GB22191@verge.net.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Cc: eric.dumazet@gmail.com, dev@openvswitch.org,
	netdev@vger.kernel.org, davem@davemloft.net
To: horms@verge.net.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.valinux.co.jp ([210.128.90.3]:50608 "EHLO
	mail.valinux.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751732AbaFCEqN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2014 00:46:13 -0400
In-Reply-To: Your message of "Tue, 3 Jun 2014 13:30:47 +0900"
	<20140603043047.GB22191@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> diff --git a/net/core/dev.c b/net/core/dev.c
> index 0355ca5..7c063ac 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2498,13 +2498,42 @@ static int dev_gso_segment(struct sk_buff *skb, netdev_features_t features)
>  	return 0;
>  }
>  
> +/* If MPLS offload request, verify we are testing hardware MPLS features
> + * instead of standard features for the netdev.
> + */
> +#ifdef CONFIG_NET_MPLS_GSO
> +static netdev_features_t net_mpls_features(struct sk_buff *skb,
> +					   netdev_features_t features,
> +					   __be16 type)
> +{
> +	int tmp;

this variable seems no longer used.

> +
> +	if (unlikely(type == htons(ETH_P_MPLS_UC) ||
> +		     type == htons(ETH_P_MPLS_MC)))

why unlikely?

otherwise,
Acked-by: YAMAMOTO Takashi <yamamoto@valinux.co.jp>

YAMAMOTO Takashi
