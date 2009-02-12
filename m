From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 29/41]bnx2x: Memory clean up on failure
Date: Thu, 12 Feb 2009 20:37:57 +0200
Message-ID: <1234463877.1863.161.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1442 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758567AbZBLSiO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Feb 2009 13:38:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Subject: [PATCH 29/41]bnx2x: Memory clean up on failure

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_init.h |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bnx2x_init.h b/drivers/net/bnx2x_init.h
index 961db49..021438f 100644
--- a/drivers/net/bnx2x_init.h
+++ b/drivers/net/bnx2x_init.h
@@ -274,6 +274,9 @@ static void bnx2x_init_wr_wb(struct bnx2x *bp, u32 addr, const u32 *data,
 		rc = bnx2x_gunzip(bp, (u8 *)data, len);
 		if (rc) {
 			BNX2X_ERR("gunzip failed ! rc %d\n", rc);
+#ifdef __BIG_ENDIAN
+			kfree(temp);
+#endif
 			return;
 		}
 		len = bp->gunzip_outlen;
-- 
1.5.4.3




