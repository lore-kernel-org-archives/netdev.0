From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [patch 2.6.11-rc4-netdev1 1/5] r8169: fix rx skb allocation error logging
Date: Tue, 22 Feb 2005 00:53:01 +0100
Message-ID: <20050221235301.GA31723@electric-eye.fr.zoreil.com>
References: <20050221235125.GD26248@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, jdmason@us.ibm.com
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20050221235125.GD26248@electric-eye.fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Fix rx skb allocation error logging

Signed arithmetic is not required as rtl8169_rx_fill() return belongs
to the [0; NUM_RX_DESC] interval.

Signed-off-by: Jon Mason <jdmason@us.ibm.com>
Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

diff -puN drivers/net/r8169.c~r8169-400 drivers/net/r8169.c
--- a/drivers/net/r8169.c~r8169-400	2005-02-17 21:50:09.820173216 +0100
+++ b/drivers/net/r8169.c	2005-02-17 22:00:00.210450784 +0100
@@ -2156,8 +2156,8 @@ static int
 rtl8169_rx_interrupt(struct net_device *dev, struct rtl8169_private *tp,
 		     void __iomem *ioaddr)
 {
-	unsigned int cur_rx, rx_left, count;
-	int delta;
+	unsigned int cur_rx, rx_left;
+	unsigned int delta, count;
 
 	assert(dev != NULL);
 	assert(tp != NULL);
@@ -2225,10 +2225,8 @@ rtl8169_rx_interrupt(struct net_device *
 	tp->cur_rx = cur_rx;
 
 	delta = rtl8169_rx_fill(tp, dev, tp->dirty_rx, tp->cur_rx);
-	if (delta < 0) {
+	if (!delta && count)
 		printk(KERN_INFO "%s: no Rx buffer allocated\n", dev->name);
-		delta = 0;
-	}
 	tp->dirty_rx += delta;
 
 	/*

_
