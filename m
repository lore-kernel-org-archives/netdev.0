From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2/6] sky2: clear status IRQ after empty
Date: Wed, 06 Sep 2006 10:17:54 -0700
Message-ID: <20060906171920.866115000@localhost.localdomain>
References: <20060906171752.781595000@localhost.localdomain>
Cc: stable@kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:2729 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751492AbWIFSRD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Sep 2006 14:17:03 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=sky2-status-clr.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Don't clear status IRQ until list has been read to avoid causing
status list wraparound. Clearing IRQ forces a Transmit Status update
if it is pending.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- linux-2.6.17.11.orig/drivers/net/sky2.c
+++ linux-2.6.17.11/drivers/net/sky2.c
@@ -2016,6 +2016,9 @@ static int sky2_status_intr(struct sky2_
 		}
 	}
 
+	/* Fully processed status ring so clear irq */
+	sky2_write32(hw, STAT_CTRL, SC_STAT_CLR_IRQ);
+
 exit_loop:
 	return work_done;
 }
@@ -2218,9 +2221,6 @@ static int sky2_poll(struct net_device *
 	*budget -= work_done;
 	dev0->quota -= work_done;
 
-	if (status & Y2_IS_STAT_BMU)
-		sky2_write32(hw, STAT_CTRL, SC_STAT_CLR_IRQ);
-
 	if (sky2_more_work(hw))
 		return 1;
 

--
Stephen Hemminger <shemminger@osdl.org>

