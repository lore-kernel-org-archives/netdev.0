From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: [e1000 netdev-2.6 3/6] disable CSA fix for 82547
Date: Sat, 21 Feb 2004 23:15:47 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0402212311420.1228-100000@localhost.localdomain>
Reply-To: "Feldman, Scott" <scott.feldman@intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, "Feldman, Scott" <scott.feldman@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


* Multiple reports of system lock-ups with the CSA patch, so
  let's disable fix for now until we can understand why this
  is causing the hangs.  It was first thought that only pre-
  productions systems would hang, but that's not true.

---------

diff -Naurp netdev-2.6/drivers/net/e1000/e1000_main.c netdev-2.6/drivers/net/e1000.mod/e1000_main.c
--- netdev-2.6/drivers/net/e1000/e1000_main.c	2004-02-20 14:07:04.000000000 -0800
+++ netdev-2.6/drivers/net/e1000.mod/e1000_main.c	2004-02-20 14:07:24.000000000 -0800
@@ -2131,26 +2131,10 @@ e1000_intr(int irq, void *data, struct p
 		__netif_rx_schedule(netdev);
 	}
 #else
-        /* Writing IMC and IMS is needed for 82547.
-	   Due to Hub Link bus being occupied, an interrupt 
-	   de-assertion message is not able to be sent. 
-	   When an interrupt assertion message is generated later,
-	   two messages are re-ordered and sent out.
-	   That causes APIC to think 82547 is in de-assertion
-	   state, while 82547 is in assertion state, resulting 
-	   in dead lock. Writing IMC forces 82547 into 
-	   de-assertion state.
-        */
-	if(hw->mac_type == e1000_82547 || hw->mac_type == e1000_82547_rev_2)
-		e1000_irq_disable(adapter);
-
 	for(i = 0; i < E1000_MAX_INTR; i++)
 		if(!e1000_clean_rx_irq(adapter) &
 		   !e1000_clean_tx_irq(adapter))
 			break;
-
-	if(hw->mac_type == e1000_82547 || hw->mac_type == e1000_82547_rev_2)
-		e1000_irq_enable(adapter);
 #endif
 
 	return IRQ_HANDLED;
