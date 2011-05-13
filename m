From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: netlink: don't try unicast when dst_pid is zero
 for NETLINK_USERSOCK
Date: Fri, 13 May 2011 16:48:16 -0400 (EDT)
Message-ID: <20110513.164816.691741982303119913.davem@davemloft.net>
References: <1305267894-3314-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:57988 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755403Ab1EMUsU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 May 2011 16:48:20 -0400
In-Reply-To: <1305267894-3314-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>
Date: Fri, 13 May 2011 14:24:54 +0800

> For NETLINK_USERSOCK, no one listens on PID 0, so sending a message only to
> to a multicast group should not return -ECONNREFUSED.
> 
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>

I don't think this is a great idea, creating different semantics for
NETLINK_USERSOCK vs. other types.

You have to set the pid to something which will receive the unicast
message, and then you can also (on top of that) send it to a multicast
group as well.

But the base operation is always the unicast send, and that is what
determines success/failure of the operation.

I'm not applying this patch.
