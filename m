From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] tcp: Initial repair mode
Date: Sun, 04 Mar 2012 21:42:17 -0500 (EST)
Message-ID: <20120304.214217.1441761517395907331.davem@davemloft.net>
References: <4F4E4084.9080804@parallels.com>
	<4F4E40CE.9080205@parallels.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tj@kernel.org, eric.dumazet@gmail.com
To: xemul@parallels.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47844 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751228Ab2CECmY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Mar 2012 21:42:24 -0500
In-Reply-To: <4F4E40CE.9080205@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@parallels.com>
Date: Wed, 29 Feb 2012 19:14:22 +0400

> This includes (according the the previous description):
> 
> * TCP_REPAIR sockoption
> * Sequences sockoptions
> * Ability to forcibly bind a socket to a port
> * Immediate connect modification
> * Silent close modification
> 
> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

There are some assumptions about the relationship between
the receive queue, copied_seq, and these other sequence
numbers which keep track of what's happening.

There are warning and assertions that trigger any time
these values appear to be out-of-whack, for example the
WARN() checks in tcp_cleanup_rbuf() and tcp_recvmsg().

I don't see anything in this code which makes sure the
other aspects of the TCP socket are in a state such
that these assertions will not potentially trigger.
