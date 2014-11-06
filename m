From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] udp: Increment UDP_MIB_IGNOREDMULTI for
 arriving unmatched multicasts
Date: Wed, 05 Nov 2014 22:11:32 -0500 (EST)
Message-ID: <20141105.221132.564742208038564677.davem@davemloft.net>
References: <20141104234710.7FC7C290039D@tardy>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: raj@tardy.usa.hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50724 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751176AbaKFDLe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2014 22:11:34 -0500
In-Reply-To: <20141104234710.7FC7C290039D@tardy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: raj@tardy.usa.hp.com (Rick Jones)
Date: Tue,  4 Nov 2014 15:47:10 -0800 (PST)

> @@ -1656,6 +1657,7 @@ static int __udp4_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
>  	int dif = skb->dev->ifindex;
>  	unsigned int count = 0, offset = offsetof(typeof(*sk), sk_nulls_node);
>  	unsigned int hash2 = 0, hash2_any = 0, use_hash2 = (hslot->count > 10);
> +	unsigned int inner_flushed = 0;
>  
>  	if (use_hash2) {
>  		hash2_any = udp4_portaddr_hash(net, htonl(INADDR_ANY), hnum) &
 ...
> @@ -781,6 +781,7 @@ static int __udp6_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
>  	int dif = inet6_iif(skb);
>  	unsigned int count = 0, offset = offsetof(typeof(*sk), sk_nulls_node);
>  	unsigned int hash2 = 0, hash2_any = 0, use_hash2 = (hslot->count > 10);
> +	int inner_flushed = 0;

Please use bool/true/false for inner_flushed in these two functions.

Thanks.
