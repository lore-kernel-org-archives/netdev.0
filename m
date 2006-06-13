From: Stephen Hemminger <shemminger@osdl.org>
Subject: [RFT 3/5] sky2: suspend/resume patchlets
Date: Tue, 13 Jun 2006 17:17:29 +0900
Message-ID: <20060613081930.598695000@localhost.localdomain>
References: <20060613081726.695812000@localhost.localdomain>
Cc: linus@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:24555 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750759AbWFMIUk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jun 2006 04:20:40 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline; filename=sky2-poll-complete.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Subject: [RFT 3/5] sky2: fix hotplug detect during poll

Linus, doesn't understand NAPI.
If the poll routine detects no hardware available, it needs to dequeue
it self from the network poll list.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- test.orig/drivers/net/sky2.c
+++ test/drivers/net/sky2.c
@@ -2181,7 +2181,7 @@ static int sky2_poll(struct net_device *
 	u32 status = sky2_read32(hw, B0_Y2_SP_EISR);
 
 	if (!~status)
-		return 0;
+		goto out;
 
 	if (status & Y2_IS_HW_ERR)
 		sky2_hw_intr(hw);
@@ -2219,7 +2219,7 @@ static int sky2_poll(struct net_device *
 
 	if (sky2_more_work(hw))
 		return 1;
-
+out:
 	netif_rx_complete(dev0);
 
 	sky2_read32(hw, B0_Y2_SP_LISR);

--

