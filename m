From: David Gibson <david@gibson.dropbear.id.au>
Subject: [2/5] Orinoco merge updates, part the fourth: ignore_disconnect flag
Date: Wed, 30 Mar 2005 13:44:03 +1000
Message-ID: <20050330034403.GH6478@localhost.localdomain>
References: <20050330034238.GF6478@localhost.localdomain> <20050330034316.GG6478@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261747AbVC3Dq0@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>, Pavel Roskin <proski@gnu.org>,
	Orinoco Development List <orinoco-devel@lists.sourceforge.net>,
	netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20050330034316.GG6478@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adds an ignore_disconnect module parameter.  When enabled, the driver
will continue attempting to send packets even when the firmware has
told us we've lost our link to the AP.  On some firmwares this
substantially increases the usable range of the card (presumably
because we have an interrmittent connection, but the firmware is able
to queue the packets for us until we're connected again).  On some
other cards, it causes the firmware to fall in a screaming heap :(
(hence, default off).

Signed-off-by: David Gibson <hermes@gibson.dropbear.id.au>

Index: working-2.6/drivers/net/wireless/orinoco.c
===================================================================
--- working-2.6.orig/drivers/net/wireless/orinoco.c	2005-03-11 14:44:09.000000000 +1100
+++ working-2.6/drivers/net/wireless/orinoco.c	2005-03-11 14:51:33.000000000 +1100
@@ -492,6 +492,9 @@
 static int suppress_linkstatus; /* = 0 */
 module_param(suppress_linkstatus, bool, 0644);
 MODULE_PARM_DESC(suppress_linkstatus, "Don't log link status changes");
+static int ignore_disconnect; /* = 0 */
+module_param(ignore_disconnect, int, 0644);
+MODULE_PARM_DESC(ignore_disconnect, "Don't report lost link to the network layer");
 
 /********************************************************************/
 /* Compile time configuration and compatibility stuff               */
@@ -1320,7 +1323,7 @@
 
 		if (connected)
 			netif_carrier_on(dev);
-		else
+		else if (!ignore_disconnect)
 			netif_carrier_off(dev);
 
 		if (newstatus != priv->last_linkstatus)

-- 
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist, thank you.  NOT _the_ _other_
				| _way_ _around_!
http://www.ozlabs.org/people/dgibson
