From: David Miller <davem@davemloft.net>
Subject: Re: sunvnet and ->xmit_more
Date: Tue, 07 Oct 2014 16:46:49 -0400 (EDT)
Message-ID: <20141007.164649.587971614591244924.davem@davemloft.net>
References: <20141007192922.GA31406@oracle.com>
	<20141007.153829.1919460115976279645.davem@davemloft.net>
	<9BB04EDE-1842-4DB0-93BE-5186B2D187AB@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sowmini.varadhan@oracle.com, netdev@vger.kernel.org,
	david.stevens@oracle.com
To: Raghuram.Kothakota@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48501 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754939AbaJGUqv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2014 16:46:51 -0400
In-Reply-To: <9BB04EDE-1842-4DB0-93BE-5186B2D187AB@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Raghuram Kothakota <Raghuram.Kothakota@oracle.com>
Date: Tue, 7 Oct 2014 13:38:07 -0700

> In case of sunvnet,  consumer starting as soon as possible would help
> as the consumer is slower as it copies the data to local buffers. The recent
> change by DLS avoids the copy in the Tx side, so the producer could be
> faster than the receiver.  If the trigger is sent after n packets, then consumer
> will really start after n packets in the ring and it may have lost that much time
> to pickup the packets.

I agree for the first few TX queue entires, or even just the first, but after
that it always pays to defer and decrease the number of hcalls, locks, etc.

Play with it, you'll see.
