From: Roy Marples <uberlord@gentoo.org>
Subject: [PATCH] prism54: set carrier flags correctly
Date: Thu, 7 Dec 2006 15:47:05 +0000
Message-ID: <200612071547.05987.uberlord@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from rsm.demon.co.uk ([80.177.111.50]:45153 "EHLO mail.marples.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759440AbWLGPrQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Dec 2006 10:47:16 -0500
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

prism54 should set the carrier flags correctly when it thinks the link can be used.

Signed-off-by: Roy Marples <uberlord@gentoo.org>

--- a/drivers/net/wireless/prism54/isl_ioctl.c	2006-08-24 10:48:50.000000000 +0100
+++ b/drivers/net/wireless/prism54/isl_ioctl.c	2006-08-24 10:29:32.000000000 +0100
@@ -1573,8 +1573,11 @@
 		} else
 			send_simple_event(netdev_priv(ndev),
 					  "Link established");
-	} else
+		netif_carrier_on(ndev);
+	} else {
 		send_simple_event(netdev_priv(ndev), "Link lost");
+		netif_carrier_off(ndev);
+	}
 }
 
 /* Beacon/ProbeResp payload header */
--- a/drivers/net/wireless/prism54/islpci_dev.c	2006-08-24 10:48:50.000000000 +0100
+++ b/drivers/net/wireless/prism54/islpci_dev.c	2006-08-24 10:30:31.000000000 +0100
@@ -387,7 +387,9 @@
 	}
 
 	netif_start_queue(ndev);
-/*      netif_mark_up( ndev ); */
+
+	/* Turn off carrier unless we know we have associated */
+	netif_carrier_off(ndev);
 
 	return 0;
 }
