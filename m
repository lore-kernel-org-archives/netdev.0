From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 2.6.9-rc3-mm2 5/5] r8169: cleanup
Date: Mon, 4 Oct 2004 21:53:02 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041004195302.GD20379@electric-eye.fr.zoreil.com>
References: <20041004194826.GA18404@electric-eye.fr.zoreil.com> <20041004194949.GA20379@electric-eye.fr.zoreil.com> <20041004195051.GB20379@electric-eye.fr.zoreil.com> <20041004195216.GC20379@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, akpm@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Content-Disposition: inline
In-Reply-To: <20041004195216.GC20379@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Cleanup
- timeout message is redundant with net/sched/sch_generic::dev_watchdog;
- anti-bloat in rtl8169_get_rx_csum;
- format fix.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Signed-off-by: Jon Mason <jdmason@us.ibm.com>

diff -puN drivers/net/r8169.c~r8169-220 drivers/net/r8169.c
--- linux-2.6.9-rc3/drivers/net/r8169.c~r8169-220	2004-10-04 21:26:36.000000000 +0200
+++ linux-2.6.9-rc3-fr/drivers/net/r8169.c	2004-10-04 21:27:47.000000000 +0200
@@ -660,10 +660,10 @@ static u32 rtl8169_get_rx_csum(struct ne
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 
-	return !!(tp->cp_cmd & RxChkSum);
+	return tp->cp_cmd & RxChkSum;
 }
 
-static int rtl8169_set_rx_csum(struct net_device *dev,  u32 data)
+static int rtl8169_set_rx_csum(struct net_device *dev, u32 data)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 	void *ioaddr = tp->mmio_addr;
@@ -1774,8 +1774,6 @@ static void rtl8169_tx_timeout(struct ne
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 
-	printk(KERN_INFO "%s: TX Timeout\n", dev->name);
-
 	rtl8169_hw_reset(tp->mmio_addr);
 
 	/* Let's wait a bit while any (async) irq lands on */
@@ -2176,7 +2174,7 @@ rtl8169_interrupt(int irq, void *dev_ins
 		if (likely(netif_rx_schedule_prep(dev)))
 			__netif_rx_schedule(dev);
 		else {
-			printk(KERN_INFO "%s: interrupt %x taken in poll\n",
+			printk(KERN_INFO "%s: interrupt %04x taken in poll\n",
 			       dev->name, status);	
 		}
 		break;

_
