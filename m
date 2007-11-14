From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] PATCH 1/2 [SCHED 2.6.24]: Check subqueue status before
 calling hard_start_xmit
Date: Tue, 13 Nov 2007 20:41:14 -0800 (PST)
Message-ID: <20071113.204114.28838694.davem@davemloft.net>
References: <20071113174444.27916.1892.stgit@localhost.localdomain>
	<20071113174450.27916.80538.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: peter.p.waskiewicz.jr@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55140
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758835AbXKNElP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2007 23:41:15 -0500
In-Reply-To: <20071113174450.27916.80538.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>
Date: Tue, 13 Nov 2007 09:44:50 -0800

> The only qdiscs that check subqueue state before dequeue'ing are PRIO
> and RR.  The other qdiscs, including the default pfifo_fast qdisc, will
> allow traffic bound for subqueue 0 through to hard_start_xmit.  The check
> for netif_queue_stopped() is done above in pkt_sched.h, so it is
> unnecessary for qdisc_restart().  However, if the underlying driver is
> multiqueue capable, and only sets queue states on subqueues, this will
> allow packets to enter the driver when it's currently unable to process
> packets, resulting in expensive requeues and driver entries.  This patch
> re-adds the check for the subqueue status before calling hard_start_xmit,
> so we can try and avoid the driver entry when the queues are stopped.
> 
> Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>

Applied, and I'll queue up the other one for -stable, thanks.
