From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: e1000 close (NAPI)
Date: Tue, 7 Oct 2003 14:34:37 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <16258.45789.42373.575294@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, Robert Olsson <Robert.Olsson@data.slu.se>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: scott.feldman@intel.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



 Hello!


 Here is an patch to check netif_running in dev->poll so we don't have to hang in 
 dev_close until all polls are finished.


 Cheers.
						--ro


--- drivers/net/e1000/e1000_main.c.031007	2003-05-08 16:29:08.000000000 +0200
+++ drivers/net/e1000/e1000_main.c	2003-10-07 14:26:12.000000000 +0200
@@ -2040,7 +2040,7 @@
 	*budget -= work_done;
 	netdev->quota -= work_done;
 	
-	if(work_done < work_to_do) {
+	if(work_done < work_to_do || !netif_running(netdev)) {
 		netif_rx_complete(netdev);
 		e1000_irq_enable(adapter);
 	}
