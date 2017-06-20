From: Benjamin Gaignard <benjamin.gaignard@linaro.org>
Subject: [PATCH 03/51] net: broadcom: stop using rtc deprecated functions
Date: Tue, 20 Jun 2017 11:35:11 +0200
Message-ID: <1497951359-13334-4-git-send-email-benjamin.gaignard@linaro.org>
References: <1497951359-13334-1-git-send-email-benjamin.gaignard@linaro.org>
Cc: linaro-kernel@lists.linaro.org,
        Michael Chan <michael.chan@broadcom.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: benjamin.gaignard@linaro.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1497951359-13334-1-git-send-email-benjamin.gaignard@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

rtc_time_to_tm() and rtc_tm_to_time() are deprecated because they
rely on 32bits variables and that will make rtc break in y2038/2016.
Stop using those two functions to safer 64bits ones.

Signed-off-by: Benjamin Gaignard <benjamin.gaignard@linaro.org>
CC: Michael Chan <michael.chan@broadcom.com>
CC: netdev@vger.kernel.org
CC: linux-kernel@vger.kernel.org
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index b56c54d..9fef202 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -4703,7 +4703,7 @@ int bnxt_hwrm_fw_set_time(struct bnxt *bp)
 		return -EOPNOTSUPP;
 
 	do_gettimeofday(&tv);
-	rtc_time_to_tm(tv.tv_sec, &tm);
+	rtc_time64_to_tm(tv.tv_sec, &tm);
 	bnxt_hwrm_cmd_hdr_init(bp, &req, HWRM_FW_SET_TIME, -1, -1);
 	req.year = cpu_to_le16(1900 + tm.tm_year);
 	req.month = 1 + tm.tm_mon;
-- 
1.9.1
