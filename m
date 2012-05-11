From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] l2tp: fix reorder timeout recovery
Date: Thu, 10 May 2012 23:27:50 -0400 (EDT)
Message-ID: <20120510.232750.775841370291639964.davem@davemloft.net>
References: <1336642989-4785-1-git-send-email-jchapman@katalix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jchapman@katalix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56648 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932440Ab2EKD14 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2012 23:27:56 -0400
In-Reply-To: <1336642989-4785-1-git-send-email-jchapman@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: James Chapman <jchapman@katalix.com>
Date: Thu, 10 May 2012 10:43:08 +0100

> When L2TP data packet reordering is enabled, packets are held in a
> queue while waiting for out-of-sequence packets. If a packet gets
> lost, packets will be held until the reorder timeout expires, when we
> are supposed to then advance to the sequence number of the next packet
> but we don't currently do so. As a result, the data channel is stuck
> because we are waiting for a packet that will never arrive - all
> packets age out and none are passed.
> 
> The fix is to add a flag to the session context, which is set when the
> reorder timeout expires and tells the receive code to reset the next
> expected sequence number to that of the next packet in the queue.
> 
> Tested in a production L2TP network with Starent and Nortel L2TP gear.
> 
> Signed-off-by: James Chapman <jchapman@katalix.com>

Applied, but reorder_skip should really be a 'bool'.
