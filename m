From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [PATCH 2.6 2/14] e1000: Fix kernel panic when the interface is
 brought down while the NAPI enabled driver is under stress
Date: Thu, 6 Jan 2005 17:21:00 -0800 (PST)
Message-ID: <Pine.LNX.4.44.0501061523010.7330-100000@isotope.jf.intel.com>
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
@@ -2162,6 +2162,9 @@ e1000_clean(struct net_device *netdev, i
 	int tx_cleaned;
 	int work_done = 0;
 	
+	if (!netif_carrier_ok(netdev))
+		goto quit_polling;
+
 	tx_cleaned = e1000_clean_tx_irq(adapter);
 	e1000_clean_rx_irq(adapter, &work_done, work_to_do);
 
@@ -2171,7 +2174,7 @@ e1000_clean(struct net_device *netdev, i
 	/* if no Rx and Tx cleanup work was done, exit the polling mode */
 	if(!tx_cleaned || (work_done < work_to_do) || 
 				!netif_running(netdev)) {
-		netif_rx_complete(netdev);
+quit_polling:	netif_rx_complete(netdev);
 		e1000_irq_enable(adapter);
 		return 0;
 	}
