From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netlink: change nlmsg_notify() return value logic
Date: Wed, 25 Feb 2009 06:35:57 +0100
Message-ID: <49A4D8BD.4090701@trash.net>
References: <20090225025502.4716.3568.stgit@Decadence>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51690 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751856AbZBYFgA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2009 00:36:00 -0500
In-Reply-To: <20090225025502.4716.3568.stgit@Decadence>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pablo Neira Ayuso wrote:
> This patch changes the return value of nlmsg_notify() as follows:
> 
> If NETLINK_BROADCAST_ERROR is set by any of the listeners and
> an error in the delivery happened, return the broadcast error;
> else if there are no listeners apart from the socket that
> requested a change with the echo flag, return the result of the
> unicast notification. Thus, with this patch, the unicast
> notification is handled in the same way of a broadcast listener
> that has set the NETLINK_BROADCAST_ERROR socket flag.

Seems reasonable.

> This patch is useful in case that the caller of nlmsg_notify()
> wants to know the result of the delivery of a netlink notification
> (including the broadcast delivery) and take any action in case
> that the delivery failed. For example, ctnetlink can drop packets
> if the event delivery failed to provide reliable logging and
> state-synchronization at the cost of dropping packets.
> 
> This patch also modifies the rtnetlink code to ignore the return
> value of rtnl_notify() in all callers. The function rtnl_notify()
> (before this patch) returned the error of the unicast notification
> which makes rtnl_set_sk_err() reports errors to all listeners. This
> is not of any help since the origin of the change (the socket that
> requested the echoing) notices the ENOBUFS error if the notification
> fails and should resync itself.

Also makes sense.

Acked-by: Patrick McHardy <kaber@trash.net>
