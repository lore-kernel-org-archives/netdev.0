From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 5/7] [ibmtr]: Use netif_carrier_* instead of IFF_RUNNING and remove obsolete usage of IFF_RUNNING
Date: Mon, 28 Mar 2005 02:09:31 +0200
Message-ID: <20050328000931.GS3086@postel.suug.ch>
References: <20050328000610.GN3086@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, mikep@linuxtr.net
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20050328000610.GN3086@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2005/03/28 00:16:54+02:00 tgraf@suug.ch 
#   [ibmtr]: Use netif_carrier_* instead of IFF_RUNNING and remove obsolete usage of IFF_RUNNING
#   
#   Signed-off-by: Thomas Graf <tgraf@suug.ch>
# 
# drivers/net/tokenring/ibmtr.c
#   2005/03/28 00:16:44+02:00 tgraf@suug.ch +3 -8
#   [ibmtr]: Use netif_carrier_* instead of IFF_RUNNING and remove obsolete usage of IFF_RUNNING
# 
diff -Nru a/drivers/net/tokenring/ibmtr.c b/drivers/net/tokenring/ibmtr.c
--- a/drivers/net/tokenring/ibmtr.c	2005-03-28 01:07:47 +02:00
+++ b/drivers/net/tokenring/ibmtr.c	2005-03-28 01:07:47 +02:00
@@ -888,11 +888,6 @@
 	ti->sap_status   = CLOSED; /* CLOSED or OPEN      */
 	ti->open_failure =     NO; /* NO     or YES       */
 	ti->open_mode    = MANUAL; /* MANUAL or AUTOMATIC */
-	/* 12/2000 not typical Linux, but we can use RUNNING to let us know when
-	the network has crapped out or cables are disconnected. Useful because
-	the IFF_UP flag stays up the whole time, until ifconfig tr0 down.
-	*/
-	dev->flags &= ~IFF_RUNNING;
 
 	ti->sram_phys &= ~1; /* to reverse what we do in tok_close */
 	/* init the spinlock */
@@ -1242,7 +1237,7 @@
 		ti->open_status = CLOSED;
 		ti->sap_status  = CLOSED;
 		ti->open_mode   = AUTOMATIC;
-		dev->flags &= ~IFF_RUNNING;
+		netif_carrier_off(dev);
 		netif_stop_queue(dev);
 		ti->open_action = RESTART;
 		outb(0, dev->base_addr + ADAPTRESET);
@@ -1323,7 +1318,7 @@
 				break;
 			}
 			netif_wake_queue(dev);
-			dev->flags |= IFF_RUNNING;/*BMS 12/2000*/
+			netif_carrier_on(dev);
 			break;
 		case DIR_INTERRUPT:
 		case DIR_MOD_OPEN_PARAMS:
@@ -1427,7 +1422,7 @@
 								ring_status);
 			if(ring_status& (REMOVE_RECV|AUTO_REMOVAL|LOBE_FAULT)){
 				netif_stop_queue(dev);
-				dev->flags &= ~IFF_RUNNING;/*not typical Linux*/
+				netif_carrier_off(dev);
 				DPRINTK("Remove received, or Auto-removal error"
 					", or Lobe fault\n");
 				DPRINTK("We'll try to reopen the closed adapter"
