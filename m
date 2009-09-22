From: John Linn <john.linn@xilinx.com>
Subject: [PATCH] net: xilinx_emaclite: Fix problem with first incoming packet
Date: Tue, 22 Sep 2009 09:24:14 -0600
Message-ID: <fac40d47-5b19-4225-9fee-f7a058851fc0@SG2EHSMHS017.ehs.local>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Michal Simek <monstr@monstr.eu>
To: netdev@vger.kernel.org, davem@davemloft.net,
	linuxppc-dev@ozlabs.org, grant.likely@secretlab.ca,
	jwboyer@linux.vnet.ibm.com, sadanand.mutyala@xilinx.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from sg2ehsobe002.messaging.microsoft.com ([207.46.51.76]:17279 "EHLO
	SG2EHSOBE002.bigfish.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756873AbZIVPYW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2009 11:24:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Simek <monstr@monstr.eu>

You can't ping the board or connect to it unless you send
any packet out from board.

Tested-by: John Williams <john.williams@petalogix.com>
Signed-off-by: Michal Simek <monstr@monstr.eu>
Acked-by: John Linn <john.linn@xilinx.com>
---
 drivers/net/xilinx_emaclite.c |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/net/xilinx_emaclite.c b/drivers/net/xilinx_emaclite.c
index dc22782..83a044d 100644
--- a/drivers/net/xilinx_emaclite.c
+++ b/drivers/net/xilinx_emaclite.c
@@ -134,18 +134,15 @@ static void xemaclite_enable_interrupts(struct net_local *drvdata)
 	}
 
 	/* Enable the Rx interrupts for the first buffer */
-	reg_data = in_be32(drvdata->base_addr + XEL_RSR_OFFSET);
 	out_be32(drvdata->base_addr + XEL_RSR_OFFSET,
-		 reg_data | XEL_RSR_RECV_IE_MASK);
+		 XEL_RSR_RECV_IE_MASK);
 
 	/* Enable the Rx interrupts for the second Buffer if
 	 * configured in HW */
 	if (drvdata->rx_ping_pong != 0) {
-		reg_data = in_be32(drvdata->base_addr + XEL_BUFFER_OFFSET +
-				   XEL_RSR_OFFSET);
 		out_be32(drvdata->base_addr + XEL_BUFFER_OFFSET +
 			 XEL_RSR_OFFSET,
-			 reg_data | XEL_RSR_RECV_IE_MASK);
+			 XEL_RSR_RECV_IE_MASK);
 	}
 
 	/* Enable the Global Interrupt Enable */
-- 
1.6.2.1



This email and any attachments are intended for the sole use of the named recipient(s) and contain(s) confidential information that may be proprietary, privileged or copyrighted under applicable law. If you are not the intended recipient, do not read, copy, or forward this email message or any attachments. Delete this email message and any attachments immediately.


