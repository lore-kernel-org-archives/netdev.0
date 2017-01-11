From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] bnxt_en: hide unused bnxt_get_max_func_{vnics,rss_ctxs} functions
Date: Wed, 11 Jan 2017 15:36:09 +0100
Message-ID: <20170111143619.502495-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
        "David S. Miller" <davem@davemloft.net>,
        Prashant Sreedharan <prashant.sreedharan@broadcom.com>,
        Satish Baddipadige <sbaddipa@broadcom.com>,
        Alexander Duyck <aduyck@mirantis.com>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Michael Chan <michael.chan@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are lots of #ifdefs in this file, and a recent patch got one
of them wrong, leading to a harmless warning in some randconfig
builds:

ethernet/broadcom/bnxt/bnxt.c:4956:21: error: 'bnxt_get_max_func_vnics' defined but not used [-Werror=unused-function]
ethernet/broadcom/bnxt/bnxt.c:4947:21: error: 'bnxt_get_max_func_rss_ctxs' defined but not used [-Werror=unused-function]

Ideally we'd just remove all of them and use 'if (IS_ENABLED())'
checks instead, which don't have this problem, but for now, I'm
adding one more #ifdef to shut up the new warning.

Fixes: 8079e8f107bf ("bnxt_en: Refactor code that determines RFS capability.")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 7bd2a85694dd..c0918507fdb4 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -4944,6 +4944,7 @@ static int bnxt_setup_int_mode(struct bnxt *bp)
 	return rc;
 }
 
+#ifdef CONFIG_RFS_ACCEL
 static unsigned int bnxt_get_max_func_rss_ctxs(struct bnxt *bp)
 {
 #if defined(CONFIG_BNXT_SRIOV)
@@ -4961,6 +4962,7 @@ static unsigned int bnxt_get_max_func_vnics(struct bnxt *bp)
 #endif
 	return bp->pf.max_vnics;
 }
+#endif
 
 unsigned int bnxt_get_max_func_stat_ctxs(struct bnxt *bp)
 {
-- 
2.9.0
