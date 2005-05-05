From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [patch linux-2.6.12-rc3-mm3 7/7] r8169: cleanup (function args)
Date: Fri, 6 May 2005 01:06:31 +0200
Message-ID: <20050505230631.GF18393@electric-eye.fr.zoreil.com>
References: <20050504221057.1e02a402.akpm@osdl.org> <20050505115502.GA4414@electric-eye.fr.zoreil.com> <20050505110052.62c1c2cb.akpm@osdl.org> <20050505225656.GA11200@electric-eye.fr.zoreil.com> <20050505225905.GA18393@electric-eye.fr.zoreil.com> <20050505230016.GB18393@electric-eye.fr.zoreil.com> <20050505230154.GC18393@electric-eye.fr.zoreil.com> <20050505230313.GD18393@electric-eye.fr.zoreil.com> <20050505230418.GE18393@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
In-Reply-To: <20050505230418.GE18393@electric-eye.fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

minor cleanup

- more consistent function arguments;
- rtl8169_rx_interrupt()
  o the error condition should be rare;
  o goto removal.

Signed-off-by: Richard Dawe <rich@phekda.gotadsl.co.uk>
Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

diff -puN drivers/net/r8169.c~r8169-580 drivers/net/r8169.c
--- a/drivers/net/r8169.c~r8169-580	2005-05-06 00:40:32.031341377 +0200
+++ b/drivers/net/r8169.c	2005-05-06 00:40:32.059336850 +0200
@@ -457,10 +457,10 @@ static void rtl8169_hw_start(struct net_
 static int rtl8169_close(struct net_device *dev);
 static void rtl8169_set_rx_mode(struct net_device *dev);
 static void rtl8169_tx_timeout(struct net_device *dev);
-static struct net_device_stats *rtl8169_get_stats(struct net_device *netdev);
+static struct net_device_stats *rtl8169_get_stats(struct net_device *dev);
 static int rtl8169_rx_interrupt(struct net_device *, struct rtl8169_private *,
 				void __iomem *);
-static int rtl8169_change_mtu(struct net_device *netdev, int new_mtu);
+static int rtl8169_change_mtu(struct net_device *dev, int new_mtu);
 static void rtl8169_down(struct net_device *dev);
 
 #ifdef CONFIG_R8169_NAPI
@@ -2360,7 +2360,7 @@ rtl8169_rx_interrupt(struct net_device *
 	rx_left = NUM_RX_DESC + tp->dirty_rx - cur_rx;
 	rx_left = rtl8169_rx_quota(rx_left, (u32) dev->quota);
 
-	while (rx_left > 0) {
+	for (; rx_left > 0; rx_left--, cur_rx++) {
 		unsigned int entry = cur_rx % NUM_RX_DESC;
 		struct RxDesc *desc = tp->RxDescArray + entry;
 		u32 status;
@@ -2370,7 +2370,7 @@ rtl8169_rx_interrupt(struct net_device *
 
 		if (status & DescOwn)
 			break;
-		if (status & RxRES) {
+		if (unlikely(status & RxRES)) {
 			if (netif_msg_rx_err(tp)) {
 				printk(KERN_INFO
 				       "%s: Rx ERROR. status = %08x\n",
@@ -2397,7 +2397,7 @@ rtl8169_rx_interrupt(struct net_device *
 				tp->stats.rx_dropped++;
 				tp->stats.rx_length_errors++;
 				rtl8169_mark_to_asic(desc, tp->rx_buf_sz);
-				goto move_on;
+				continue;
 			}
 
 			rtl8169_rx_csum(skb, desc);
@@ -2426,9 +2426,6 @@ rtl8169_rx_interrupt(struct net_device *
 			tp->stats.rx_bytes += pkt_size;
 			tp->stats.rx_packets++;
 		}
-move_on:		
-		cur_rx++; 
-		rx_left--;
 	}
 
 	count = cur_rx - tp->cur_rx;

_
