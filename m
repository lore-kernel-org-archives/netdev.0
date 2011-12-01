From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: Cannot communicate with brX when its MAC
 address is changed
Date: Wed, 30 Nov 2011 23:02:18 -0500 (EST)
Message-ID: <20111130.230218.710206942884045715.davem@davemloft.net>
References: <4ED5E9D6.3070404@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, bridge@lists.linux-foundation.org,
	netdev@vger.kernel.org
To: sanagi.koki@jp.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58198 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753799Ab1LAECZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2011 23:02:25 -0500
In-Reply-To: <4ED5E9D6.3070404@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
Date: Wed, 30 Nov 2011 17:31:18 +0900

> When the MAC address of a bridge interface is changed, it cannot communicate
> with others. Because Whether or not a packet should be transferred to bridge
> interface depends on whether or not dst of a packet is in fdb and is_local=y.
> If we change MAC address of a bridge interface, it isn't in fdb.
> 
> This patch adds an condition that dst of a packet matches MAC address of
> a bridge interface to the conventional condition.
> 
> Signed-off-by: Koki Sanagi <sanagi.koki@jp.fujitsu.com>

This looks like a patch I've seen before, and in any event it makes
more sense to update the FDB when the MAC changes instead of adding a
special bypass rule.

Stephen?

> ---
>  net/bridge/br_input.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/net/bridge/br_input.c b/net/bridge/br_input.c
> index 5a31731..4e5c862 100644
> --- a/net/bridge/br_input.c
> +++ b/net/bridge/br_input.c
> @@ -94,7 +94,8 @@ int br_handle_frame_finish(struct sk_buff *skb)
>  			skb2 = skb;
>  
>  		br->dev->stats.multicast++;
> -	} else if ((dst = __br_fdb_get(br, dest)) && dst->is_local) {
> +	} else if ((dst = __br_fdb_get(br, dest) && dst->is_local) ||
> +		   !compare_ether_addr(p->br->dev->dev_addr, dest)) {
>  		skb2 = skb;
>  		/* Do not forward the packet since it's local. */
>  		skb = NULL;
