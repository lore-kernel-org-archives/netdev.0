From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 09/10] sky2: no message on rx fifo overflow
Date: Wed, 11 Oct 2006 14:22:34 -0700
Message-ID: <20061011212311.543258132@osdl.org>
References: <20061011212225.941046083@osdl.org>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:10189 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1161413AbWJKVZt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2006 17:25:49 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=sky2-no-overflow-msg.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Under high load it is possible to make the receiver FIFO get overloaded.
The driver/hardware recover properly, so there is no reason to fill the log
with lots of extra messages, just update counter.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

---
 drivers/net/sky2.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

--- sky2.orig/drivers/net/sky2.c	2006-10-11 12:05:46.000000000 -0700
+++ sky2/drivers/net/sky2.c	2006-10-11 12:05:54.000000000 -0700
@@ -2014,6 +2014,10 @@
 
 error:
 	++sky2->net_stats.rx_errors;
+	if (status & GMR_FS_RX_FF_OV) {
+		sky2->net_stats.rx_fifo_errors++;
+		goto resubmit;
+	}
 
 	if (netif_msg_rx_err(sky2) && net_ratelimit())
 		printk(KERN_INFO PFX "%s: rx error, status 0x%x length %d\n",
@@ -2025,8 +2029,6 @@
 		sky2->net_stats.rx_frame_errors++;
 	if (status & GMR_FS_CRC_ERR)
 		sky2->net_stats.rx_crc_errors++;
-	if (status & GMR_FS_RX_FF_OV)
-		sky2->net_stats.rx_fifo_errors++;
 
 	goto resubmit;
 }

--
Stephen Hemminger <shemminger@osdl.org>

