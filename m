From: Don Fry <brazilnut@us.ibm.com>
Subject: [PATCH 2.4.25] pcnet32.c non-mii errors with ethtool
Date: Fri, 20 Feb 2004 16:27:49 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200402210027.i1L0Rnx07520@DYN318364BLD.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: tsbogend@alpha.franken.de, jgarzik@pobox.com, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

pcnet32 devices which do not contain an mii respond incorrectly to
ethtool commands.

Reported by VANDROVE@vc.cvut.cz and Thomas Munck Steenholdt.

--- linux-2.4.25/drivers/net/clean.pcnet32.c	Fri Feb 20 12:05:10 2004
+++ linux-2.4.25/drivers/net/pcnet32.c	Fri Feb 20 16:18:37 2004
@@ -469,25 +469,31 @@
 
 static int pcnet32_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	struct pcnet32_private *lp = dev->priv;
-	unsigned long flags;
+    struct pcnet32_private *lp = dev->priv;
+    unsigned long flags;
+    int r = -EOPNOTSUPP;
 
+    if (lp->mii) {
 	spin_lock_irqsave(&lp->lock, flags);
 	mii_ethtool_gset(&lp->mii_if, cmd);
 	spin_unlock_irqrestore(&lp->lock, flags);
-	return 0;
+	r = 0;
+    }
+    return r;
 }
 
 static int pcnet32_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-	struct pcnet32_private *lp = dev->priv;
-	unsigned long flags;
-	int r;
+    struct pcnet32_private *lp = dev->priv;
+    unsigned long flags;
+    int r = -EOPNOTSUPP;
 
+    if (lp->mii) {
 	spin_lock_irqsave(&lp->lock, flags);
 	r = mii_ethtool_sset(&lp->mii_if, cmd);
 	spin_unlock_irqrestore(&lp->lock, flags);
-	return r;
+    }
+    return r;
 }
 
 static void pcnet32_get_drvinfo(struct net_device *dev, struct ethtool_drvinfo *info)
@@ -504,14 +510,16 @@
 
 static u32 pcnet32_get_link(struct net_device *dev)
 {
-	struct pcnet32_private *lp = dev->priv;
-	unsigned long flags;
-	int r;
+    struct pcnet32_private *lp = dev->priv;
+    unsigned long flags;
+    int r = 1;
 
+    if (lp->mii) {
 	spin_lock_irqsave(&lp->lock, flags);
 	r = mii_link_ok(&lp->mii_if);
 	spin_unlock_irqrestore(&lp->lock, flags);
-	return r;
+    }
+    return r;
 }
 
 static u32 pcnet32_get_msglevel(struct net_device *dev)
@@ -528,14 +536,16 @@
   
 static int pcnet32_nway_reset(struct net_device *dev)
 {
-	struct pcnet32_private *lp = dev->priv;
-	unsigned long flags;
-	int r;
+    struct pcnet32_private *lp = dev->priv;
+    unsigned long flags;
+    int r = -EOPNOTSUPP;
 
+    if (lp->mii) {
 	spin_lock_irqsave(&lp->lock, flags);
 	r = mii_nway_restart(&lp->mii_if);
 	spin_unlock_irqrestore(&lp->lock, flags);
-	return r;
+    }
+    return r;
 }
 
 static void pcnet32_get_ringparam(struct net_device *dev, struct ethtool_ringparam *ering)

-- 
Don Fry
brazilnut@us.ibm.com
