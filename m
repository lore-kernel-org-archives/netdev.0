From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] net: remove erroneous sk null assignment in timestamping
Date: Fri, 07 Oct 2011 13:33:56 -0400 (EDT)
Message-ID: <20111007.133356.489094996618032061.davem@davemloft.net>
References: <1318007501.3988.20.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, richardcochran@gmail.com
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:47904 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754435Ab1JGRfD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Oct 2011 13:35:03 -0400
In-Reply-To: <1318007501.3988.20.camel@jlt3.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Fri, 07 Oct 2011 19:11:41 +0200

> From: Johannes Berg <johannes.berg@intel.com>
> 
> skb->sk is obviously required to be non-NULL
> when we get into skb_complete_tx_timestamp().
> sock_queue_err_skb() will call skb_orphan()
> first thing which sets skb->sk = NULL itself.
> This may crash if the skb is still charged to
> the socket (skb->destructor is sk_wfree).
> 
> The assignment here thus seems to not only be
> pointless (due to the skb_orphan() call) but
> also dangerous (due to the crash).
> 
> Signed-off-by: Johannes Berg <johannes.berg@intel.com>

It looks like skb_clone_tx_timestamp() sets clone->sk without any
proper refcounting, so I bet this NULL'ing it out is working
around that bug.

The TX side of this infrastructure seems very poorly tested.
