From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (1/4) acenic - use netdev_priv
Date: Mon, 20 Sep 2004 10:44:55 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040920104455.6cb37915@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jes Sorensen <jes@wildopensource.com>, Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Trivial, use netdev_priv 

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
 
diff -Nru a/drivers/net/acenic.c b/drivers/net/acenic.c
--- a/drivers/net/acenic.c	2004-09-20 10:46:22 -07:00
+++ b/drivers/net/acenic.c	2004-09-20 10:46:22 -07:00
@@ -1618,7 +1618,7 @@
 
 static void ace_tasklet(unsigned long dev)
 {
-	struct ace_private *ap = ((struct net_device *)dev)->priv;
+	struct ace_private *ap = netdev_priv((struct net_device *)dev);
 	int cur_size;
 
 	cur_size = atomic_read(&ap->cur_rx_bufs);
diff -Nru a/drivers/net/acenic.h b/drivers/net/acenic.h
--- a/drivers/net/acenic.h	2004-09-20 10:46:22 -07:00
+++ b/drivers/net/acenic.h	2004-09-20 10:46:22 -07:00
@@ -750,7 +750,7 @@
 
 static inline void ace_mask_irq(struct net_device *dev)
 {
-	struct ace_private *ap = dev->priv;
+	struct ace_private *ap = netdev_priv(dev);
 	struct ace_regs *regs = ap->regs;
 
 	if (ACE_IS_TIGON_I(ap))
@@ -764,7 +764,7 @@
 
 static inline void ace_unmask_irq(struct net_device *dev)
 {
-	struct ace_private *ap = dev->priv;
+	struct ace_private *ap = netdev_priv(dev);
 	struct ace_regs *regs = ap->regs;
  
 	if (ACE_IS_TIGON_I(ap))
