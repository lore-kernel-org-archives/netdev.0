From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [PATCH 2.4 6/13] e1000: Synchronizing multicast table setup with
 transmit path - ak@suse.de
Date: Thu, 6 Jan 2005 17:09:47 -0800 (PST)
Message-ID: <Pine.LNX.4.44.0501061505080.7330-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
diff -up net-drivers-2.4/drivers/net/e1000/e1000_main.c net-drivers-2.4/drivers/net/e1000.new/e1000_main.c
--- net-drivers-2.4/drivers/net/e1000/e1000_main.c	2004-12-06 08:43:11.635381920 -0800
+++ net-drivers-2.4/drivers/net/e1000.new/e1000_main.c	2004-12-06 08:43:12.534245272 -0800
@@ -1260,9 +1260,12 @@ e1000_set_multi(struct net_device *netde
 	uint32_t rctl;
 	uint32_t hash_value;
 	int i;
+	unsigned long flags;
 
 	/* Check for Promiscuous and All Multicast modes */
 
+	spin_lock_irqsave(&adapter->tx_lock, flags);
+
 	rctl = E1000_READ_REG(hw, RCTL);
 
 	if(netdev->flags & IFF_PROMISC) {
@@ -1311,6 +1314,8 @@ e1000_set_multi(struct net_device *netde
 
 	if(hw->mac_type == e1000_82542_rev2_0)
 		e1000_leave_82542_rst(adapter);
+
+	spin_unlock_irqrestore(&adapter->tx_lock, flags);
 }
 
 /* Need to wait a few seconds after link up to get diagnostic information from
