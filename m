From: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
Subject: [PATCH] 3c59x - use netdev_priv
Date: Mon, 27 Sep 2004 15:50:45 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040927135045.GC18851@gareth.mathematik.tu-chemnitz.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Patch changes the two remaining direct accessing of dev->priv to netdev_priv.

Applies against linux-2.6.9-rc2-mm3

Signed-off-by: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>

--  

diff -urN vanilla-2.6.9-rc2-mm3/drivers/net/3c59x.c linux-2.6.9-rc2-mm3/drivers/net/3c59x.c
--- vanilla-2.6.9-rc2-mm3/drivers/net/3c59x.c	Sat Sep 25 12:00:58 2004
+++ linux-2.6.9-rc2-mm3/drivers/net/3c59x.c	Mon Sep 27 10:27:07 2004
@@ -934,7 +934,7 @@ static int vortex_cards_found;
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void poll_vortex(struct net_device *dev)
 {
-	struct vortex_private *vp = (struct vortex_private *)dev->priv;
+	struct vortex_private *vp = netdev_priv(dev);
 	unsigned long flags;
 	local_save_flags(flags);
 	local_irq_disable();
@@ -2982,7 +2982,7 @@ static void set_rx_mode(struct net_devic
 
 static void set_8021q_mode(struct net_device *dev, int enable)
 {
-	struct vortex_private *vp = (struct vortex_private *)dev->priv;
+	struct vortex_private *vp = netdev_priv(dev);
 	long ioaddr = dev->base_addr;
 	int old_window = inw(ioaddr + EL3_CMD);
 	int mac_ctrl;
