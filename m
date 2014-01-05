From: Yuval Mintz <yuvalmin@broadcom.com>
Subject: [PATCH net 4/5] bnx2x: fix AFEX memory overflow
Date: Sun, 5 Jan 2014 18:33:53 +0200
Message-ID: <1388939634-19948-5-git-send-email-yuvalmin@broadcom.com>
References: <1388939634-19948-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <ariele@broadcom.com>, Yuval Mintz <yuvalmin@broadcom.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:52626 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751454AbaAEQeE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jan 2014 11:34:04 -0500
In-Reply-To: <1388939634-19948-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are 2 different (related) flows in the slowpath configuration
that utilize the same pointer and cast it to different structs;
This is obviously incorrect as the intended allocated memory is that
of the smaller struct, possibly causing the flow utilizing the larger
struct to corrupt other slowpath configuration.

Since both flows are exclusive, set the allocated memory to be a union
of both structs.

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index cb30d1a..2d5fce4 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -1250,7 +1250,10 @@ struct bnx2x_slowpath {
 	 * Therefore, if they would have been defined in the same union,
 	 * data can get corrupted.
 	 */
-	struct afex_vif_list_ramrod_data func_afex_rdata;
+	union {
+		struct afex_vif_list_ramrod_data	viflist_data;
+		struct function_update_data		func_update;
+	} func_afex_rdata;
 
 	/* used by dmae command executer */
 	struct dmae_command		dmae[MAX_DMAE_C];
-- 
1.8.1.227.g44fe835
