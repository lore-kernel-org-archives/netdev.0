From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 1/3] bnx2x: Adding restriction on sge_buf_size
Date: Mon, 09 Mar 2009 12:52:14 +0200
Message-ID: <1236595934.11030.12.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Alex Chiang" <achiang@hp.com>,
	"Bjorn Helgaas" <bjorn.helgaas@hp.com>,
	"Vladislav Zolotarov" <vladz@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4565 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753500AbZCIKxL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Mar 2009 06:53:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Subject: [PATCH 1/3] bnx2x: Adding restriction on sge_buf_size.

sge_buff_size may not be more than 0xffff.

Reported-by: Bjorn Helgaas <bjorn.helgaas@hp.com>
Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
Tested-by: Bjorn Helgaas <bjorn.helgaas@hp.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index d3e7775..48127f1 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -4518,7 +4518,8 @@ static void bnx2x_init_context(struct bnx2x *bp)
 				(USTORM_ETH_ST_CONTEXT_CONFIG_ENABLE_TPA |
 				 USTORM_ETH_ST_CONTEXT_CONFIG_ENABLE_SGE_RING);
 			context->ustorm_st_context.common.sge_buff_size =
-					(u16)(BCM_PAGE_SIZE*PAGES_PER_SGE);
+				(u16)min((u32)SGE_PAGE_SIZE*PAGES_PER_SGE,
+					 (u32)0xffff);
 			context->ustorm_st_context.common.sge_page_base_hi =
 						U64_HI(fp->rx_sge_mapping);
 			context->ustorm_st_context.common.sge_page_base_lo =
-- 
1.5.6.3




