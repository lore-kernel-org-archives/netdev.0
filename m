From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 04/18] bnx2x: Add rmb to read status block indices on
 load
Date: Mon, 02 Mar 2009 19:59:27 +0200
Message-ID: <1236016767.7723.75.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2320 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755653AbZCBSA3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Mar 2009 13:00:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Subject: [PATCH 04/18] bnx2x: Add rmb to read status block indices on load

Add rmb to read status block indices on load

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index fbd0f88..e4d54e1 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -5154,6 +5154,10 @@ static void bnx2x_nic_init(struct bnx2x *bp, u32 load_code)
 		bnx2x_update_fpsb_idx(fp);
 	}
 
+	/* ensure status block indices were read */
+	rmb();
+
+
 	bnx2x_init_def_sb(bp, bp->def_status_blk, bp->def_status_blk_mapping,
 			  DEF_SB_ID);
 	bnx2x_update_dsb_idx(bp);
-- 
1.5.4.3




