From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net/8021q: Check the correct vlan filter capability
Date: Wed, 24 Feb 2016 11:48:39 -0500 (EST)
Message-ID: <20160224.114839.300751853393269073.davem@davemloft.net>
References: <1456331959-3573-1-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, galp@mellanox.com, ogerlitz@mellanox.com,
	kaber@trash.net
To: saeedm@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54474 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754418AbcBXQso (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2016 11:48:44 -0500
In-Reply-To: <1456331959-3573-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>
Date: Wed, 24 Feb 2016 18:39:19 +0200

> From: Gal Pressman <galp@mellanox.com>
> 
> Use dev->hw_features in vlan_hw_filter_capable instead of dev->features,
> since dev->features can be turned on/off dynamically.
> 
> Netdev features can be changed dynamically to off after vlan_vid_add
> was called, thus vlan_vid_del will skip ndo_vlan_rx_kill_vid and will
> leave the device driver with un-freed resources.

Are you sure the fix isn't to make vlan_vid_add() check ->features instead
of ->hw_features.

Should we really be trying to add VLAN filters when the user has
turned it off?
