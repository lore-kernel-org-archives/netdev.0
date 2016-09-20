From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next] bnxt_en: Fix build error for kernesl without RTC-LIB
Date: Tue, 20 Sep 2016 03:36:33 -0400
Message-ID: <1474356993-5857-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:36258 "EHLO
        mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751297AbcITHgo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 03:36:44 -0400
Received: by mail-pa0-f47.google.com with SMTP id id6so4324745pad.3
        for <netdev@vger.kernel.org>; Tue, 20 Sep 2016 00:36:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rob Swindell <swindell@broadcom.com>

bnxt_hwrm_fw_set_time() now returns -EOPNOTSUPP when built for kernel
without RTC_LIB.  Setting the firmware time is not critical to the
successful completion of the firmware update process.

Signed-off-by: Rob Swindell <Rob.Swindell@broadcom.com>
Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index cbc0b8a..a9f9f37 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -4323,6 +4323,7 @@ hwrm_ver_get_exit:
 
 int bnxt_hwrm_fw_set_time(struct bnxt *bp)
 {
+#if IS_ENABLED(CONFIG_RTC_LIB)
 	struct hwrm_fw_set_time_input req = {0};
 	struct rtc_time tm;
 	struct timeval tv;
@@ -4340,6 +4341,9 @@ int bnxt_hwrm_fw_set_time(struct bnxt *bp)
 	req.minute = tm.tm_min;
 	req.second = tm.tm_sec;
 	return hwrm_send_message(bp, &req, sizeof(req), HWRM_CMD_TIMEOUT);
+#else
+	return -EOPNOTSUPP;
+#endif
 }
 
 static int bnxt_hwrm_port_qstats(struct bnxt *bp)
-- 
1.8.3.1
