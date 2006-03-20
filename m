From: Martin Michlmayr <tbm@cyrius.com>
Subject: [PATCH 5/12] [NET] Bring declance.c in sync with linux-mips tree
Date: Mon, 20 Mar 2006 04:39:53 +0000
Message-ID: <20060320043953.GE20416@deprecation.cyrius.com>
References: <20060320043802.GA20389@deprecation.cyrius.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linux-mips@linux-mips.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751467AbWCTEk3@vger.kernel.org>
To: akpm@osdl.org
Content-Disposition: inline
In-Reply-To: <20060320043802.GA20389@deprecation.cyrius.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are three changes between the Linus' and linux-mips git trees
regarding the declaner driver.  Two are cosmetic and one fixes a
call to the wrong function.

Signed-off-by: Martin Michlmayr <tbm@cyrius.com>
Acked-by: Maciej W. Rozycki <macro@linux-mips.org>


--- linux-2.6/drivers/net/declance.c	2006-03-05 19:35:04.000000000 +0000
+++ mips.git/drivers/net/declance.c	2006-03-05 18:51:15.000000000 +0000
@@ -704,8 +704,8 @@
 	return IRQ_HANDLED;
 }
 
-static irqreturn_t
-lance_interrupt(const int irq, void *dev_id, struct pt_regs *regs)
+static irqreturn_t lance_interrupt(const int irq, void *dev_id,
+				   struct pt_regs *regs)
 {
 	struct net_device *dev = (struct net_device *) dev_id;
 	struct lance_private *lp = netdev_priv(dev);
@@ -1255,7 +1255,7 @@
 	return 0;
 
 err_out_free_dev:
-	kfree(dev);
+	free_netdev(dev);
 
 err_out:
 	return ret;
@@ -1301,6 +1301,7 @@
 	while (root_lance_dev) {
 		struct net_device *dev = root_lance_dev;
 		struct lance_private *lp = netdev_priv(dev);
+
 		unregister_netdev(dev);
 #ifdef CONFIG_TC
 		if (lp->slot >= 0)

-- 
Martin Michlmayr
http://www.cyrius.com/
