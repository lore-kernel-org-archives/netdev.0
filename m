From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [Patch 2/16 2.5] ixgb: Fix memory leak in NAPI mode. Avoid unnecessary
 work in NAPI Rx cleanup
Date: Fri, 15 Oct 2004 06:54:14 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0410150620330.31227-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -up net-drivers-2.6/drivers/net/ixgb/ixgb_main.c net-drivers-2.6/drivers/net/ixgb.new/ixgb_main.c
--- net-drivers-2.6/drivers/net/ixgb/ixgb_main.c	2004-10-05 15:50:18.000000000 -0700
+++ net-drivers-2.6/drivers/net/ixgb.new/ixgb_main.c	2004-10-05 17:55:48.000000000 -0700
@@ -1790,6 +1790,12 @@ ixgb_clean_rx_irq(struct ixgb_adapter *a
 
 	while (rx_desc->status & IXGB_RX_DESC_STATUS_DD) {
 
+#ifdef CONFIG_IXGB_NAPI
+		if(*work_done >= work_to_do)
+			break;
+
+		(*work_done)++;
+#endif
 		skb = buffer_info->skb;
 		prefetch(skb->data);
 
@@ -1807,12 +1824,6 @@ ixgb_clean_rx_irq(struct ixgb_adapter *a
 		next_skb = next_buffer->skb;
 		prefetch(next_skb);
 
-#ifdef CONFIG_IXGB_NAPI
-		if (*work_done >= work_to_do)
-			break;
-
-		(*work_done)++;
-#endif
 
 		cleaned = TRUE;
 
