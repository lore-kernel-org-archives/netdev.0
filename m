From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: [e1000 2.6-exp] back out CSA interrupt fix
Date: Sun, 4 Jan 2004 16:43:48 -0800 (PST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0401041636240.20704-100000@localhost.localdomain>
Reply-To: "Feldman, Scott" <scott.feldman@intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, "Feldman, Scott" <scott.feldman@intel.com>,
        <cramerj@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


* 8086:1019 82547 CSA-based LOMs lock up the system with
  this code, so let's revert back to what's in 2.6.0 until
  we can figure out why this is causing problems.

---------

--- net-drivers-2.5-exp/drivers/net/e1000/e1000_main.c.orig	2004-01-04 15:58:59.000000000 -0800
+++ net-drivers-2.5-exp/drivers/net/e1000/e1000_main.c	2004-01-04 15:59:32.000000000 -0800
@@ -2097,26 +2097,10 @@
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
