From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netlink/genetlink: pass network namespace to
 bind/unbind
Date: Sat, 27 Dec 2014 03:08:05 -0500 (EST)
Message-ID: <20141227.030805.2148263042773135498.davem@davemloft.net>
References: <1419364806-8753-1-git-send-email-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, johannes.berg@intel.com
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50393 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751079AbaL0Siq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Dec 2014 13:38:46 -0500
In-Reply-To: <1419364806-8753-1-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Tue, 23 Dec 2014 21:00:06 +0100

> From: Johannes Berg <johannes.berg@intel.com>
> 
> Netlink families can exist in multiple namespaces, and for the most
> part multicast subscriptions are per network namespace. Thus it only
> makes sense to have bind/unbind notifications per network namespace.
> 
> To achieve this, pass the network namespace of a given client socket
> to the bind/unbind functions.
> 
> Also do this in generic netlink, and there also make sure that any
> bind for multicast groups that only exist in init_net is rejected.
> This isn't really a problem if it is accepted since a client in a
> different namespace will never receive any notifications from such
> a group, but it can confuse the family if not rejected (it's also
> possible to silently (without telling the family) accept it, but it
> would also have to be ignored on unbind so families that take any
> kind of action on bind/unbind won't do unnecessary work for invalid
> clients like that.
> 
> Signed-off-by: Johannes Berg <johannes.berg@intel.com>

Applied, thanks Johannes.
