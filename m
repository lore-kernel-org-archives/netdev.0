From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net 4/6] bnx2x: prevent VF benign attentions
Date: Mon, 19 Aug 2013 09:11:59 +0300
Message-ID: <1376892721-10410-5-git-send-email-yuvalmin@broadcom.com>
References: <1376892721-10410-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: ariele@broadcom.com, eilong@broadcom.com,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2733 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750981Ab3HSGMW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Aug 2013 02:12:22 -0400
In-Reply-To: <1376892721-10410-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

During probe, VFs might erroneously try to access the shared memory (which
only PFs are capabale of accessing), causing benign attentions to appear.

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index b8d7c3b..8bdc8b9 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -11163,6 +11163,9 @@ static bool bnx2x_get_dropless_info(struct bnx2x *bp)
 	int tmp;
 	u32 cfg;
 
+	if (IS_VF(bp))
+		return 0;
+
 	if (IS_MF(bp) && !CHIP_IS_E1x(bp)) {
 		/* Take function: tmp = func */
 		tmp = BP_ABS_FUNC(bp);
-- 
1.8.1.227.g44fe835
