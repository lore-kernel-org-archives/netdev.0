From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [Patch 1/16 2.5] ixgb: Fix VLAN filter setup errors (while running
 on PPC)
Date: Fri, 15 Oct 2004 06:54:05 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0410150619030.31227-100000@isotope.jf.intel.com>
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
@@ -1863,9 +1863,8 @@ ixgb_clean_rx_irq(struct ixgb_adapter *a
 		if (adapter->vlgrp
 		    && (rx_desc->status & IXGB_RX_DESC_STATUS_VP)) {
 			vlan_hwaccel_receive_skb(skb, adapter->vlgrp,
-						 le16_to_cpu(rx_desc->
-							     special &
-							     IXGB_RX_DESC_SPECIAL_VLAN_MASK));
+				le16_to_cpu(rx_desc->special) &
+					IXGB_RX_DESC_SPECIAL_VLAN_MASK);
 		} else {
 			netif_receive_skb(skb);
 		}
@@ -1873,9 +1873,8 @@ 
 		if (adapter->vlgrp
 		    && (rx_desc->status & IXGB_RX_DESC_STATUS_VP)) {
 			vlan_hwaccel_rx(skb, adapter->vlgrp,
-					le16_to_cpu(rx_desc->
-						    special &
-						    IXGB_RX_DESC_SPECIAL_VLAN_MASK));
+				le16_to_cpu(rx_desc->special) &
+					IXGB_RX_DESC_SPECIAL_VLAN_MASK);
 		} else {
 			netif_rx(skb);
 		}
