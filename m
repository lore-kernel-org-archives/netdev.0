From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [patch 3/5 2.4] e1000 - Fix VLAN filter setup errors (while running
 on PPC)
Date: Fri, 17 Sep 2004 02:56:05 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0409170221060.15233-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: ganesh.venkatesan@intel.com, <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -up linux-2.4/drivers/net/e1000/e1000_main.c linux-2.4/drivers/net/e1000.new/e1000_main.c
--- linux-2.4/drivers/net/e1000/e1000_main.c	2004-09-16 08:09:07.000000000 -0700
+++ linux-2.4/drivers/net/e1000.new/e1000_main.c	2004-09-16 08:09:08.000000000 -0700
@@ -2345,8 +2345,8 @@ e1000_clean_rx_irq(struct e1000_adapter 
 		if(unlikely(adapter->vlgrp &&
 			    (rx_desc->status & E1000_RXD_STAT_VP))) {
 			vlan_hwaccel_receive_skb(skb, adapter->vlgrp,
-				le16_to_cpu(rx_desc->special &
-					E1000_RXD_SPC_VLAN_MASK));
+					le16_to_cpu(rx_desc->special) &
+					E1000_RXD_SPC_VLAN_MASK);
 		} else {
 			netif_receive_skb(skb);
 		}
@@ -2354,8 +2354,8 @@ 
 		if(unlikely(adapter->vlgrp &&
 			    (rx_desc->status & E1000_RXD_STAT_VP))) {
 			vlan_hwaccel_rx(skb, adapter->vlgrp,
-				le16_to_cpu(rx_desc->special &
-					E1000_RXD_SPC_VLAN_MASK));
+					le16_to_cpu(rx_desc->special) &
+					E1000_RXD_SPC_VLAN_MASK);
 		} else {
 			netif_rx(skb);
 		}
