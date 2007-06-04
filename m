From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 1/4] b44: timer power saving
Date: Mon, 04 Jun 2007 13:25:37 -0700
Message-ID: <20070604202712.223155106@linux-foundation.org>
References: <20070604202536.503165465@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Gary Zambrano <zambrano@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:59466 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753416AbXFDUkv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jun 2007 16:40:51 -0400
Content-Disposition: inline; filename=b44-modtimer.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Make the PHY and statistic timer run on one second boundary
for powersaving.

On resume, the driver should check for link up immediately, to
get online faster (rather than waiting for the next second).

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>


---
 drivers/net/b44.c |    9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

--- a/drivers/net/b44.c	2007-06-04 12:31:27.000000000 -0700
+++ b/drivers/net/b44.c	2007-06-04 12:31:34.000000000 -0700
@@ -599,8 +599,7 @@ static void b44_timer(unsigned long __op
 
 	spin_unlock_irq(&bp->lock);
 
-	bp->timer.expires = jiffies + HZ;
-	add_timer(&bp->timer);
+	mod_timer(&bp->timer, round_jiffies(jiffies + HZ));
 }
 
 static void b44_tx(struct b44 *bp)
@@ -2348,11 +2347,11 @@ static int b44_resume(struct pci_dev *pd
 	netif_device_attach(bp->dev);
 	spin_unlock_irq(&bp->lock);
 
-	bp->timer.expires = jiffies + HZ;
-	add_timer(&bp->timer);
-
 	b44_enable_ints(bp);
 	netif_wake_queue(dev);
+
+	mod_timer(&bp->timer, jiffies + 1);
+
 	return 0;
 }
 

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

