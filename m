From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] datagram: Extend the datagram queue MSG_PEEK-ing
Date: Wed, 15 Feb 2012 15:52:26 -0500 (EST)
Message-ID: <20120215.155226.1446930776120577759.davem@davemloft.net>
References: <4F352182.6060601@parallels.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tj@kernel.org, netdev@vger.kernel.org
To: xemul@parallels.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60609 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755401Ab2BOUwg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2012 15:52:36 -0500
In-Reply-To: <4F352182.6060601@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@parallels.com>
Date: Fri, 10 Feb 2012 17:54:10 +0400

> We're working on the checkpoint-restore project. To checkpoint a unix socket
> we need to read its skb queue. Analogous task for TCP sockets Tejun proposed
> to solve with parasite + recvmsg + MSG_PEEK. That's nice, but doesn't work
> for unix sockets, because for them MSG_PEEK always peeks a single skb from the 
> head of the queue.
> 
> I propose to extend the MSG_PEEK functionality with two more flags that peek
> either next not picked skb in queue or pick the last picked one. The latter
> ability is required to make it possible to re-read a message if MSG_TRUNC
> was reported on it.
> 
> These two flags can be used for unix stream sockets, since making the MSG_PEEK
> just report all data that fits the buffer length is bad -- we may have scms
> in queue thus turning stream socket into dgram one.
> 
> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

I'm still thinking about how I feel about this.

But meanwhile you can fix some thing up, for example I really
feel that you should make sure that multiple bits aren't set
at the same time.

You either mean MSG_PEEK_MORE or MSG_PEEK_AGAIN, so setting both
makes no sense and should be flagged as an error.
