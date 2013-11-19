From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC] net: rework recvmsg handler msg_name and
 msg_namelen logic
Date: Tue, 19 Nov 2013 15:40:58 -0500 (EST)
Message-ID: <20131119.154058.2058377571860676832.davem@davemloft.net>
References: <20131119052759.GR16541@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57918 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751939Ab3KSUlA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Nov 2013 15:41:00 -0500
In-Reply-To: <20131119052759.GR16541@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Tue, 19 Nov 2013 06:27:59 +0100

> This patch now always passes msg->msg_namelen as 0. recvmsg handlers must
> set msg_namelen to the proper size <= sizeof(struct sockaddr_storage)
> to return msg_name to the user.
> 
> This prevents numerous uninitialized memory leaks we had in the
> recvmsg handlers and makes it harder for new code to accidentally leak
> uninitialized memory.
> 
> Optimize for the case recvfrom is called with NULL as address. We don't
> need to copy the address at all, so set it to NULL before invoking the
> recvmsg handler. We can do so, because all the recvmsg handlers must
> cope with the case a plain read() is called on them. read() also sets
> msg_name to NULL.
> 
> Also document these changes in include/linux/net.h as suggested by David
> Miller.
> 
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Looks good to me.

The only other invoker of ->recvmsg is vhost.c but it sets msg_name to NULL
and msg_namelen to 0 so should be fine.
