From: Malli Chilakala <mallikarjuna.chilakala@intel.com>
Subject: [resend][PATCH net-drivers-2.6 12/16] e1000: Modified e1000_clean::
 exit poll
Date: Thu, 28 Apr 2005 19:43:28 -0700 (PDT)
Message-ID: <Pine.LNX.4.44.0504281931180.29290-100000@isotope.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "jgarzik@pobox.com" <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Modified e1000_clean:: exit poll if no Tx and work_done == 0

Signed-off-by: Mallikarjuna R Chilakala <mallikarjuna.chilakala@intel.com>
Signed-off-by: Ganesh Venkatesan <ganesh.venkatesan@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>
diff -up net-drivers-2.6/drivers/net/e1000/e1000_main.c net-drivers-2.6/drivers/net/e1000.new/e1000_main.c
--- net-drivers-2.6/drivers/net/e1000/e1000_main.c	2005-04-11 02:22:27.000000000 -0700
+++ net-drivers-2.6/drivers/net/e1000.new/e1000_main.c	2005-04-11 02:22:29.000000000 -0700
@@ -2368,9 +2368,8 @@ e1000_clean(struct net_device *netdev, i
 	*budget -= work_done;
 	netdev->quota -= work_done;
 	
-	/* if no Tx and not enough Rx work done, exit the polling mode */
-	if((!tx_cleaned && (work_done < work_to_do)) || 
-				!netif_running(netdev)) {
+	/* If no Tx and no Rx work done, exit the polling mode */
+	if ((!tx_cleaned && (work_done == 0)) || !netif_running(netdev)) {
 		netif_rx_complete(netdev);
 		e1000_irq_enable(adapter);
 		return 0;
