From: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Subject: [PATCH 2.4 2/13] e1000: Fix for kernel panic when the interface is
 brought down while the NAPI enabled driver is under stress
Date: Thu, 6 Jan 2005 17:05:07 -0800 (PST)
Message-ID: <Pine.LNX.4.44.0501061459560.7330-100000@isotope.jf.intel.com>
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
@@ -2147,6 +2147,9 @@ e1000_clean(struct net_device *netdev, i
 	int tx_cleaned;
 	int work_done = 0;
 	
+	if (!netif_carrier_ok(netdev))
+		goto quit_polling;
+
 	tx_cleaned = e1000_clean_tx_irq(adapter);
 	e1000_clean_rx_irq(adapter, &work_done, work_to_do);
 
@@ -2156,7 +2159,7 @@ e1000_clean(struct net_device *netdev, i
 	/* if no Rx and Tx cleanup work was done, exit the polling mode */
 	if(!tx_cleaned || (work_done < work_to_do) || 
 				!netif_running(netdev)) {
-		netif_rx_complete(netdev);
+quit_polling:	netif_rx_complete(netdev);
 		e1000_irq_enable(adapter);
 		return 0;
 	}
