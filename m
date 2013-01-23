From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 11/12] bnx2x: Fix compilation with
 stop-on-error
Date: Wed, 23 Jan 2013 15:21:53 +0200
Message-ID: <1358947314-3851-12-git-send-email-yuvalmin@broadcom.com>
References: <1358947314-3851-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, ariele@broadcom.com,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1137 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755675Ab3AWOW1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jan 2013 09:22:27 -0500
In-Reply-To: <1358947314-3851-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 823e1d9 caused bnx2x to fail once BNX2X_STOP_ON_ERROR is set.
Fixes compilation by moving function declarations between header files.

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h     | 2 ++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h | 2 --
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index 55ae8f9..e4605a9 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -122,6 +122,8 @@ do {								 \
 		dev_info(&bp->pdev->dev, fmt, ##__VA_ARGS__);	 \
 } while (0)
 
+/* Error handling */
+void bnx2x_panic_dump(struct bnx2x *bp, bool disable_int);
 #ifdef BNX2X_STOP_ON_ERROR
 #define bnx2x_panic()				\
 do {						\
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
index 4635c02..aee7671 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
@@ -479,8 +479,6 @@ int bnx2x_set_power_state(struct bnx2x *bp, pci_power_t state);
  */
 void bnx2x_update_max_mf_config(struct bnx2x *bp, u32 value);
 /* Error handling */
-void bnx2x_panic_dump(struct bnx2x *bp, bool disable_int);
-
 void bnx2x_fw_dump_lvl(struct bnx2x *bp, const char *lvl);
 
 /* validate currect fw is loaded */
-- 
1.8.1.227.g44fe835
