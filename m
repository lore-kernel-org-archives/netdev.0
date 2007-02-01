From: Peter Korsgaard <jacmet@sunsite.dk>
Subject: [PATCH] net/smc911x: Match up spin lock/unlock
Date: Thu, 01 Feb 2007 16:30:56 +0100
Message-ID: <87tzy53nf3.fsf@slug.be.48ers.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
To: dustin@sensoria.com, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751850AbXBAPuw@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

smc911x_phy_configure's error handling unconditionally unlocks the
spinlock even if it wasn't locked. Patch fixes it.

Signed-off-by: Peter Korsgaard <jacmet@sunsite.dk>

---
 drivers/net/smc911x.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

Index: linux-trunk/drivers/net/smc911x.c
===================================================================
--- linux-trunk.orig/drivers/net/smc911x.c
+++ linux-trunk/drivers/net/smc911x.c
@@ -969,11 +969,11 @@
 	 * We should not be called if phy_type is zero.
 	 */
 	if (lp->phy_type == 0)
-		 goto smc911x_phy_configure_exit;
+		 goto smc911x_phy_configure_exit_nolock;
 
 	if (smc911x_phy_reset(dev, phyaddr)) {
 		printk("%s: PHY reset timed out\n", dev->name);
-		goto smc911x_phy_configure_exit;
+		goto smc911x_phy_configure_exit_nolock;
 	}
 	spin_lock_irqsave(&lp->lock, flags);
 
@@ -1042,6 +1042,7 @@
 
 smc911x_phy_configure_exit:
 	spin_unlock_irqrestore(&lp->lock, flags);
+smc911x_phy_configure_exit_nolock:
 	lp->work_pending = 0;
 }
 

-- 
Bye, Peter Korsgaard
