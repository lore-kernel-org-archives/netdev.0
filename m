From: David Miller <davem@davemloft.net>
Subject: Re: Races in net_rx_action vs netpoll?
Date: Sun, 22 Jul 2007 00:05:07 -0700 (PDT)
Message-ID: <20070722.000507.26966710.davem@davemloft.net>
References: <20070711.193320.102574858.davem@davemloft.net>
	<200707191719.21034.okir@lst.de>
	<20070719172747.7f01b38e@oldman.hamilton.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: okir@lst.de, netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41476
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753354AbXGVHFI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jul 2007 03:05:08 -0400
In-Reply-To: <20070719172747.7f01b38e@oldman.hamilton.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Thu, 19 Jul 2007 17:27:47 +0100

> Please revisit the requirements that netconsole needs and redesign
> it from scratch.  The existing code is causing too much breakage.
>
> Can it be done without breaking the semantics of network devices, or
> should we rewrite the driver interface to take have a different
> interface like netdev_sync_send_skb() that is slow, synchronous and
> non-interrupt (ie polls for completion).  Of course, then people
> will complain that netconsole traffic slows the machine down.  for
> completion.

I couldn't agree more.

Since netpoll runs outside of all of the normal netdevice locking
rules, only the people using netpoll hit all the bugs.  That means
most of us do not test out these code path, which is bad.

So, if anything, a more integrated implementation is essential.

