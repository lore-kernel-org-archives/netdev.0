From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: vlan: 802.1ad S-VLAN support
Date: Fri, 11 Nov 2011 20:22:35 -0500 (EST)
Message-ID: <20111111.202235.1981500713669985784.davem@davemloft.net>
References: <1320512055-1231037-1-git-send-email-equinox@diac24.net>
	<1320512055-1231037-2-git-send-email-equinox@diac24.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: equinox@diac24.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59324 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755075Ab1KLBZV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Nov 2011 20:25:21 -0500
In-Reply-To: <1320512055-1231037-2-git-send-email-equinox@diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Lamparter <equinox@diac24.net>
Date: Sat,  5 Nov 2011 17:54:14 +0100

> @@ -87,7 +97,8 @@ struct vlan_group {
>  					    */
>  	unsigned int		nr_vlans;
>  	struct hlist_node	hlist;	/* linked list */
> -	struct net_device **vlan_devices_arrays[VLAN_GROUP_ARRAY_SPLIT_PARTS];
> +	struct net_device **vlan_devices_arrays[VLAN_N_PROTOCOL]
> +						[VLAN_GROUP_ARRAY_SPLIT_PARTS];
>  	struct rcu_head		rcu;
>  };

This is a terrible waste of memory.  You're now using 5 times as much space,
the vast majority of which will be entirely unused.

I don't even think it's semantically correct, all these alias QinQ protocol
values don't provide completely new VLAN_ID name spaces at all.  So this
layout doesn't even make any sense, you're allowing for something that isn't
even allowed.

Rework these datastructures to eliminate the wastage please.
