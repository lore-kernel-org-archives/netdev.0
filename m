From: "Michael Chan" <mchan@broadcom.com>
Subject: [2/5][BNX2]: Add missing wait in bnx2_init_5709_context().
Date: Mon, 04 Jun 2007 17:00:35 -0700
Message-ID: <1181001635.5275.13.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: andy@greyhouse.net, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1109 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756992AbXFDXcl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jun 2007 19:32:41 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[BNX2]: Add missing wait in bnx2_init_5709_context().

For correctness, we need to wait for the MEM_INIT bit to be cleared
in the BNX2_CTX_COMMAND register before proceeding.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 5d69e5b..daa62d9 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -1778,6 +1778,12 @@ bnx2_init_5709_context(struct bnx2 *bp)
 	val = BNX2_CTX_COMMAND_ENABLED | BNX2_CTX_COMMAND_MEM_INIT | (1 << 12);
 	val |= (BCM_PAGE_BITS - 8) << 16;
 	REG_WR(bp, BNX2_CTX_COMMAND, val);
+	for (i = 0; i < 10; i++) {
+		val = REG_RD(bp, BNX2_CTX_COMMAND);
+		if (!(val & BNX2_CTX_COMMAND_MEM_INIT))
+			break;
+		udelay(2);
+	}
 	for (i = 0; i < bp->ctx_pages; i++) {
 		int j;
 


