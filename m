From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [RFC PATCH 03/13] net: Add net protocol offload registration infrustructure
Date: Thu, 15 Nov 2012 00:14:52 +0100
Message-ID: <20121114231452.GH27068@electric-eye.fr.zoreil.com>
References: <1352856254-29667-1-git-send-email-vyasevic@redhat.com> <1352856254-29667-4-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, davem@davemloft.com
To: Vlad Yasevich <vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:49996 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932216Ab2KNXiA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Nov 2012 18:38:00 -0500
Content-Disposition: inline
In-Reply-To: <1352856254-29667-4-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Vlad Yasevich <vyasevic@redhat.com> :
[...]
> diff --git a/include/net/protocol.h b/include/net/protocol.h
> index 929528c..d8ecb17 100644
> --- a/include/net/protocol.h
> +++ b/include/net/protocol.h
> @@ -77,6 +77,15 @@ struct inet6_protocol {
>  #define INET6_PROTO_GSO_EXTHDR	0x4
>  #endif
>  
> +struct net_offload {
> +	int			(*gso_send_check)(struct sk_buff *skb);
> +	struct sk_buff	       *(*gso_segment)(struct sk_buff *skb,
> +					       netdev_features_t features);
> +	struct sk_buff	      **(*gro_receive)(struct sk_buff **head,
> +					       struct sk_buff *skb);
> +	int			(*gro_complete)(struct sk_buff *skb);
> +};

Would it be worth adding a #14 where packet_offload and net_offload
share a common offload struct instead of duplicating (currently) identical
members ?

-- 
Ueimor
