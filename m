From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3]: tg3: Manage TX backlog in-driver.
Date: Fri, 20 Jun 2008 16:20:29 -0700 (PDT)
Message-ID: <20080620.162029.63979841.davem@davemloft.net>
References: <20080619.041024.116139711.davem@davemloft.net>
	<OFD7CC7687.E0D15399-ON6525746E.0038A920-6525746E.003B6162@in.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, netdev@vger.kernel.org,
	vinay@linux.vnet.ibm.com
To: krkumar2@in.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48548
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755617AbYFTXU3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jun 2008 19:20:29 -0400
In-Reply-To: <OFD7CC7687.E0D15399-ON6525746E.0038A920-6525746E.003B6162@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Krishna Kumar2 <krkumar2@in.ibm.com>
Date: Fri, 20 Jun 2008 16:18:35 +0530

> Couple of comments:
> 
> 1. The modified drivers has a backlog of upto tx_queue_len skbs
>     compared to unmodified drivers which had tx_queue_len+q->limit.
>     Won't this result in a performance hit since packet drops will
>     take place earlier?

I doubt it matters when the tx_queue_len is on the order of 1000
packets as it currently is for ethernet devices .  For single stream
TCP tests I've never seen the backlog climb past 128 packets or so.

> 2. __tg3_xmit_backlog() should check for not running too long. This
>     also means calling netif_schedule() if tx_backlog is !empty, to
>     avoid rotting packets in the backlog queue.

I'm not so sure this is an issue in practice.  We can measure
it later to make sure.

The heuristics in the driver only wake up with the wakeup threshold
number of slots become available.  So I don't think we ever batch up
more than a certain amount of work.

But I agree it is important to consider this.
