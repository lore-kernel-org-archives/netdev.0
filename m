From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Allocate RX and TX queues in alloc_netdev_mq
Date: Thu, 28 Oct 2010 10:49:42 -0700 (PDT)
Message-ID: <20101028.104942.179929434.davem@davemloft.net>
References: <alpine.DEB.1.00.1010281036350.22486@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60718
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1760242Ab0J1RtT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 13:49:19 -0400
In-Reply-To: <alpine.DEB.1.00.1010281036350.22486@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Thu, 28 Oct 2010 10:45:45 -0700 (PDT)

> Both TX and RX queue allocations in the netdev structure had been moved
> to register_device with the idea that the number of queues could be
> changed between device allocation and registration.  It was determined
> that changing the num_queues after the call to alloc_netdev_mq was not
> a good idea, so that was abandoned.  Also, some drivers call
> netif_queue_start without registering device, which causes panic
> when dev->_tx queue structure is accessed.  This patch moves queue
> allocations back to alloc_netdev_mq to fix these issues.
> 
> Signed-off-by: Tom Herbert <therbert@google.com>

Changing the TX queue state with a netif_stop_queue() call or
similar was always completely pointless and frankly a bug.

So that should not influence the motivation behind this change
at all.

In fact I _like_ that it crashes now so that we are forced
to fix these cases.

Really, the queue state is absolutely immaterial during
device allocation and registration.  It's state is
%100 "don't care" until ->open() is invoked.

So any code that touches the queue state at these earlier points in
time is completely extraneous if not broken.
