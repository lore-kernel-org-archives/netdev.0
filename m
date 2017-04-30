From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net-next] qed: Prevent warning without CONFIG_RFS_ACCEL
Date: Sun, 30 Apr 2017 12:14:44 +0300
Message-ID: <1493543684-7038-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Sudarsana.Kalluru@cavium.com>,
        Yuval Mintz <Yuval.Mintz@cavium.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0048.outbound.protection.outlook.com ([104.47.37.48]:42256
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1163843AbdD3JOx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 30 Apr 2017 05:14:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After removing the PTP related initialization from slowpath start,
the remaining PTT entry is required only in case CONFIG_RFS_ACCEL is set.
Otherwise, it leads to a warning due to it being unused.

Fixes: d179bd1699fc ("qed: Acquire/release ptt_ptp lock when enabling/disabling PTP")
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
Hi Dave,

Please consider applying this to `net-next'.

Thanks,
Yuval
---
 drivers/net/ethernet/qlogic/qed/qed_main.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_main.c b/drivers/net/ethernet/qlogic/qed/qed_main.c
index 8a5a064..59992cf 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_main.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_main.c
@@ -928,7 +928,9 @@ static int qed_slowpath_start(struct qed_dev *cdev,
 	struct qed_tunnel_info tunn_info;
 	const u8 *data = NULL;
 	struct qed_hwfn *hwfn;
+#ifdef CONFIG_RFS_ACCEL
 	struct qed_ptt *p_ptt;
+#endif
 	int rc = -EINVAL;
 
 	if (qed_iov_wq_start(cdev))
-- 
1.9.3
