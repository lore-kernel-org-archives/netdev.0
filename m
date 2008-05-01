From: Arjan van de Ven <arjan@infradead.org>
Subject: [PATCH] net: Add a WARN_ON_ONCE() to the transmit timeout function
Date: Thu, 1 May 2008 13:34:24 -0700
Message-ID: <20080501133424.678be79a@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:42191 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935962AbYEBSeu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2008 14:34:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arjan van de Ven <arjan@linux.intel.com>
Subject: [PATCH] net: Add a WARN_ON_ONCE() to the transmit timeout function

WARN_ON_ONCE() gives a stack trace including the full module list.
Having this in the kernel dump for the timeout case in the
generic netdev watchdog will help us see quicker which driver
is involved. It also allows us to collect statistics 
and patterns in terms of which drivers have this event occuring.

Suggested by Andrew Morton

Signed-off-by: Arjan van de Ven <arjan@linux.intel.com>
---
 net/sched/sch_generic.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index b741618..d355e5e 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -219,6 +219,7 @@ static void dev_watchdog(unsigned long arg)
 				printk(KERN_INFO "NETDEV WATCHDOG: %s: transmit timed out\n",
 				       dev->name);
 				dev->tx_timeout(dev);
+				WARN_ON_ONCE(1);
 			}
 			if (!mod_timer(&dev->watchdog_timer, round_jiffies(jiffies + dev->watchdog_timeo)))
 				dev_hold(dev);
-- 
1.5.4.5

