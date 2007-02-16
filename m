From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 5/6] sky2: receive error handling improvements
Date: Thu, 15 Feb 2007 16:40:34 -0800
Message-ID: <20070216004142.312942000@linux-foundation.org>
References: <20070216004028.943889000@linux-foundation.org>
Cc: netdev@vger.kernel.org, sk-drivers@lists.linux-foundation.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:40955 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422958AbXBPAq7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Feb 2007 19:46:59 -0500
Content-Disposition: inline; filename=sky2-rx-error-handle.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Don't drop oversize frame it might be a VLAN (untagged).
Use different counter for fifo overrun vs fifo error.
Print error on fifo overrrun.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>


--- sky2-dev.orig/drivers/net/sky2.c	2007-02-15 14:33:52.000000000 -0800
+++ sky2-dev/drivers/net/sky2.c	2007-02-15 15:00:38.000000000 -0800
@@ -2056,9 +2056,6 @@
 	if (!(status & GMR_FS_RX_OK))
 		goto resubmit;
 
-	if (length > dev->mtu + ETH_HLEN)
-		goto oversize;
-
 	if (length < copybreak)
 		skb = receive_copy(sky2, re, length);
 	else
@@ -2068,14 +2065,10 @@
 
 	return skb;
 
-oversize:
-	++sky2->net_stats.rx_over_errors;
-	goto resubmit;
-
 error:
 	++sky2->net_stats.rx_errors;
 	if (status & GMR_FS_RX_FF_OV) {
-		sky2->net_stats.rx_fifo_errors++;
+		sky2->net_stats.rx_over_errors++;
 		goto resubmit;
 	}
 

--
Stephen Hemminger <shemminger@linux-foundation.org>

