From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [PATCH 2.6 5/14] e1000: Avoid filling tx_ring completely -
 shemminger@osdl.org
Date: Thu, 6 Jan 2005 17:21:18 -0800 (PST)
Message-ID: <Pine.LNX.4.44.0501061529560.7330-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
diff -up net-drivers-2.6/drivers/net/e1000/e1000_main.c net-drivers-2.6/drivers/net/e1000.new/e1000_main.c
--- net-drivers-2.6/drivers/net/e1000/e1000_main.c	2004-12-03 07:24:37.090623184 -0800
+++ net-drivers-2.6/drivers/net/e1000.new/e1000_main.c	2004-12-03 07:24:38.581396552 -0800
@@ -1842,6 +1842,10 @@ e1000_xmit_frame(struct sk_buff *skb, st
 
 	netdev->trans_start = jiffies;
 
+	/* Make sure there is space in the ring for the next send. */
+	if(unlikely(E1000_DESC_UNUSED(&adapter->tx_ring) < MAX_SKB_FRAGS + 2))
+		netif_stop_queue(netdev);
+
 	spin_unlock_irqrestore(&adapter->tx_lock, flags);
 	return NETDEV_TX_OK;
 }
