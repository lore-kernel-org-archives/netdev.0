From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] tipc: prevent dropped connections due to rcvbuf
 overflow
Date: Thu, 04 Oct 2012 15:55:03 -0400 (EDT)
Message-ID: <20121004.155503.97946024839188830.davem@davemloft.net>
References: <1349358913.16011.59.camel@edumazet-glaptop>
	<1349362843-25826-1-git-send-email-erik.hugne@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jon.maloy@ericsson.com,
	ying.xue@windriver.com, paul.gortmaker@windriver.com,
	tipc-discussion@lists.sourceforge.net
To: erik.hugne@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45419 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757249Ab2JDTzF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Oct 2012 15:55:05 -0400
In-Reply-To: <1349362843-25826-1-git-send-email-erik.hugne@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <erik.hugne@ericsson.com>
Date: Thu, 4 Oct 2012 17:00:43 +0200

> From: Erik Hugne <erik.hugne@ericsson.com>
> 
> When large buffers are sent over connected TIPC sockets, it
> is likely that the sk_backlog will be filled up on the
> receiver side, but the TIPC flow control mechanism is happily
> unaware of this since that is based on message count.
> 
> The sender will receive a TIPC_ERR_OVERLOAD message when this occurs
> and drop it's side of the connection, leaving it stale on
> the receiver end.
> 
> By increasing the sk_rcvbuf to a 'worst case' value, we avoid the
> overload caused by a full backlog queue and the flow control
> will work properly.
> 
> This worst case value is the max TIPC message size times
> the flow control window, multiplied by two because a sender
> will transmit up to double the window size before a port is marked
> congested.
> We multiply this by 2 to account for the sk_buff and other overheads.
> 
> Signed-off-by: Erik Hugne <erik.hugne@ericsson.com>

Applied.
