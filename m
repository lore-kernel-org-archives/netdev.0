From: Malli Chilakala <mallikarjuna.chilakala@intel.com>
Subject: [PATCH net-drivers-2.6 3/5] ixgb: Robert Olsson's fix and refinement
 to the poll routine
Date: Tue, 15 Feb 2005 13:38:04 -0800 (PST)
Message-ID: <Pine.LNX.4.44.0502151201290.30336-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

3 Robert Olsson's fix and refinement to the poll routine
Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>
diff -up net-drivers-2.6/drivers/net/ixgb/ixgb_main.c net-drivers-2.6/drivers/net/ixgb.new/ixgb_main.c
--- net-drivers-2.6/drivers/net/ixgb/ixgb_main.c	2005-02-06 23:33:00.652031344 -0800
+++ net-drivers-2.6/drivers/net/ixgb.new/ixgb_main.c	2005-02-06 23:33:01.617884512 -0800
@@ -1669,20 +1669,16 @@ ixgb_clean(struct net_device *netdev, in
 	int work_to_do = min(*budget, netdev->quota);
 	int tx_cleaned;
 	int work_done = 0;
-	
-	if (!netif_carrier_ok(netdev))
-		goto quit_polling;
 
 	tx_cleaned = ixgb_clean_tx_irq(adapter);
 	ixgb_clean_rx_irq(adapter, &work_done, work_to_do);
 
 	*budget -= work_done;
 	netdev->quota -= work_done;
-	
-	/* if no Tx cleanup and not enough Rx work done, exit the polling mode */
-	if((!tx_cleaned && (work_done < work_to_do)) || 
-				!netif_running(netdev)) {
-quit_polling:	netif_rx_complete(netdev);
+
+	/* if no Tx and not enough Rx work done, exit the polling mode */
+	if((!tx_cleaned && (work_done == 0)) || !netif_running(netdev)) {
+		netif_rx_complete(netdev);
 		ixgb_irq_enable(adapter);
 		return 0;
 	}
	
