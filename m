From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net 4/6] bnx2x: prevent masking error from cnic
Date: Mon, 23 Sep 2013 10:12:53 +0300
Message-ID: <1379920375-10303-5-git-send-email-yuvalmin@broadcom.com>
References: <1379920375-10303-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: ariele@broadcom.com, eilong@broadcom.com,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4692 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753280Ab3IWHNb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Sep 2013 03:13:31 -0400
In-Reply-To: <1379920375-10303-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

During error flows while loading cnic the return value was incorrectly replaced
by that of bnx2x_set_real_num_queues(); If that function was to finish
successfully then the cnic would have mistakenly thought the load ended
successfully, causing issues (& panics) later on.

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 61726af..e66beff 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -2481,8 +2481,7 @@ load_error_cnic2:
 load_error_cnic1:
 	bnx2x_napi_disable_cnic(bp);
 	/* Update the number of queues without the cnic queues */
-	rc = bnx2x_set_real_num_queues(bp, 0);
-	if (rc)
+	if (bnx2x_set_real_num_queues(bp, 0))
 		BNX2X_ERR("Unable to set real_num_queues not including cnic\n");
 load_error_cnic0:
 	BNX2X_ERR("CNIC-related load failed\n");
-- 
1.8.1.4
