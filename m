From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 1/6] bnxt_en: Fix compiler warnings when CONFIG_RFS_ACCEL is not defined.
Date: Tue, 10 Jan 2017 20:12:34 -0500
Message-ID: <1484097159-21575-2-git-send-email-michael.chan@broadcom.com>
References: <1484097159-21575-1-git-send-email-michael.chan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:34005 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757056AbdAKBM5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 20:12:57 -0500
Received: by mail-pf0-f178.google.com with SMTP id 127so55771184pfg.1
        for <netdev@vger.kernel.org>; Tue, 10 Jan 2017 17:12:57 -0800 (PST)
In-Reply-To: <1484097159-21575-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  CC [M]  drivers/net/ethernet/broadcom/bnxt/bnxt.o
drivers/net/ethernet/broadcom/bnxt/bnxt.c:4947:21: warning: ‘bnxt_get_max_func_rss_ctxs’ defined but not used [-Wunused-function]
 static unsigned int bnxt_get_max_func_rss_ctxs(struct bnxt *bp)
                     ^
  CC [M]  drivers/net/ethernet/broadcom/bnxt/bnxt.o
drivers/net/ethernet/broadcom/bnxt/bnxt.c:4956:21: warning: ‘bnxt_get_max_func_vnics’ defined but not used [-Wunused-function]
 static unsigned int bnxt_get_max_func_vnics(struct bnxt *bp)
                     ^

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 7bd2a85..c091850 100644
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
1.8.3.1
