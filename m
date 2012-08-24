From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netlink: fix possible spoofing from non-root processes
Date: Fri, 24 Aug 2012 13:36:46 -0400 (EDT)
Message-ID: <20120824.133646.1032154931939291652.davem@davemloft.net>
References: <1345723751-2924-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54642 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759065Ab2HXRgs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2012 13:36:48 -0400
In-Reply-To: <1345723751-2924-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: pablo@netfilter.org
Date: Thu, 23 Aug 2012 14:09:11 +0200

> From: Pablo Neira Ayuso <pablo@netfilter.org>
> 
> Non-root user-space processes can send Netlink messages to other
> processes that are well-known for being subscribed to Netlink
> asynchronous notifications. This allows ilegitimate non-root
> process to send forged messages to Netlink subscribers.
> 
> The userspace process usually verifies the legitimate origin in
> two ways:
> 
> a) Socket credentials. If UID != 0, then the message comes from
>    some ilegitimate process and the message needs to be dropped.
> 
> b) Netlink portID. In general, portID == 0 means that the origin
>    of the messages comes from the kernel. Thus, discarding any
>    message not coming from the kernel.
> 
> However, ctnetlink sets the portID in event messages that has
> been triggered by some user-space process, eg. conntrack utility.
> So other processes subscribed to ctnetlink events, eg. conntrackd,
> know that the event was triggered by some user-space action.
> 
> Neither of the two ways to discard ilegitimate messages coming
> from non-root processes can help for ctnetlink.
> 
> This patch adds capability validation in case that dst_pid is set
> in netlink_sendmsg(). This approach is aggressive since existing
> applications using any Netlink bus to deliver messages between
> two user-space processes will break. Note that the exception is
> NETLINK_USERSOCK, since it is reserved for netlink-to-netlink
> userspace communication.
> 
> Still, if anyone wants that his Netlink bus allows netlink-to-netlink
> userspace, then they can set NL_NONROOT_SEND. However, by default,
> I don't think it makes sense to allow to use NETLINK_ROUTE to
> communicate two processes that are sending no matter what information
> that is not related to link/neighbouring/routing. They should be using
> NETLINK_USERSOCK instead for that.
> 
> Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>

Applied and queued up for -stable, thanks Pablo.
