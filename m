From: Malli Chilakala <mallikarjuna.chilakala@intel.com>
Subject: [PATCH net-drivers-2.6 1/10] e1000: Robert Olsson's fix and refinement
 to the poll routine
Date: Tue, 15 Feb 2005 13:24:56 -0800 (PST)
Message-ID: <Pine.LNX.4.44.0502151059120.30336-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@oss.sgi.com>
To: "jgarzik@pobox.com" <jgarzik@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

1 Robert Olsson's fix and refinement to the poll routine
Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>
diff -up net-drivers-2.6/drivers/net/e1000/e1000_main.c net-drivers-2.6/drivers/net/e1000.new/e1000_main.c
--- net-drivers-2.6/drivers/net/e1000/e1000_main.c	2005-02-01 23:10:24.989105880 -0800
+++ net-drivers-2.6/drivers/net/e1000.new/e1000_main.c	2005-02-01 23:10:26.709844288 -0800
@@ -2174,24 +2174,21 @@ e1000_clean(struct net_device *netdev, i
 	int tx_cleaned;
 	int work_done = 0;
 	
-	if (!netif_carrier_ok(netdev))
-		goto quit_polling;
-
 	tx_cleaned = e1000_clean_tx_irq(adapter);
 	e1000_clean_rx_irq(adapter, &work_done, work_to_do);
 
 	*budget -= work_done;
 	netdev->quota -= work_done;
 	
-	/* if no Rx and Tx cleanup work was done, exit the polling mode */
-	if(!tx_cleaned || (work_done < work_to_do) || 
+	/* if no Tx and not enough Rx work done, exit the polling mode */
+	if((!tx_cleaned && (work_done < work_to_do)) || 
 				!netif_running(netdev)) {
-quit_polling:	netif_rx_complete(netdev);
+		netif_rx_complete(netdev);
 		e1000_irq_enable(adapter);
 		return 0;
 	}
 
-	return (work_done >= work_to_do);
+	return 1;
 }
 
 #endif
	
