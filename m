From: David Miller <davem@davemloft.net>
Subject: Re: [NET_NEXT PATCH 1/2] pkt_sched: Add multiqueue scheduler
 support
Date: Thu, 28 Aug 2008 01:21:42 -0700 (PDT)
Message-ID: <20080828.012142.51698124.davem@davemloft.net>
References: <20080828011253.7909.5172.stgit@jtkirshe-mobile.jf.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org,
	alexander.h.duyck@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34466
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753018AbYH1IVr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Aug 2008 04:21:47 -0400
In-Reply-To: <20080828011253.7909.5172.stgit@jtkirshe-mobile.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Date: Wed, 27 Aug 2008 18:12:53 -0700

> This patch is intended to add a qdisc to support the new tx multiqueue
> architecture by providing a band for each hardware queue.  By doing
> this it is possible to support a different qdisc per physical hardware
> queue.
> 
> This qdisc uses the skb->queue_mapping to select which band to place
> the traffic onto.  It then uses a round robin w/ a check to see if the
> subqueue is stopped to determine which band to dequeue the packet from.
> 
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

It looks mostly fine.

But I wonder how useful this "bands" parameter is.
It behaves as follows:

1) "1" is always allowed, essentially non-multiqueue
2) ->real_num_tx_queues is always allowed
3) 0 means auto detect, which is also ->real_num_tx_queues

Everything else is rejected.

It's effectively a boolean, use all the TX queues or just one.  So
maybe that's how it should be presented and implemented.

That makes sense because the user has no way to figure out how many TX
queues are currently available.
