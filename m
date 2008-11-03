From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 1/4]bnx2x: Removing the PMF indication when unloading
Date: Mon, 03 Nov 2008 18:11:13 +0200
Message-ID: <1225728673.14568.10.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4756 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755718AbYKCQLa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Nov 2008 11:11:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When the PMF flag is set, the driver can access the HW freely. When the
driver is unloaded, it should not access the HW. The problem caused fatal
errors when "ethtool -i" was called after the calling instance was unloaded
and another instance was already loaded

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index fce7451..61152e1 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -6481,6 +6481,7 @@ load_int_disable:
 	bnx2x_free_irq(bp);
 load_error:
 	bnx2x_free_mem(bp);
+	bp->port.pmf = 0;
 
 	/* TBD we really need to reset the chip
 	   if we want to recover from this */
@@ -6791,6 +6792,7 @@ unload_error:
 	/* Report UNLOAD_DONE to MCP */
 	if (!BP_NOMCP(bp))
 		bnx2x_fw_command(bp, DRV_MSG_CODE_UNLOAD_DONE);
+	bp->port.pmf = 0;
 
 	/* Free SKBs, SGEs, TPA pool and driver internals */
 	bnx2x_free_skbs(bp);
-- 
1.5.4.3




