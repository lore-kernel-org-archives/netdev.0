From: Yuval Mintz <Yuval.Mintz@cavium.com>
Subject: [PATCH net] qed: Don't log missing periodic stats by default
Date: Mon, 29 May 2017 11:24:49 +0300
Message-ID: <1496046289-17330-1-git-send-email-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@cavium.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0048.outbound.protection.outlook.com ([104.47.42.48]:5046
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750966AbdE2IZc (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 29 May 2017 04:25:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Current implementation lacks the logic for providing management
firmware with RDMA-related statistics; [much] worse than that -
it logs such events by default to system logs.

Since the statistics' gathering is done periodically, using sufficiently
new management firmware the system logs would get filled with these
unnecessary prints.

For now, reduce the verbosity of the log so that it would not be
logged by default.

Fixes: 6c75424612a7 ("qed: Add support for NCSI statistics")
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
Hi Dave,

Please consider applying this to `net'.

Thanks,
Yuval
---
 drivers/net/ethernet/qlogic/qed/qed_main.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed_main.c b/drivers/net/ethernet/qlogic/qed/qed_main.c
index 537d123..715b3aa 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_main.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_main.c
@@ -1730,7 +1730,8 @@ void qed_get_protocol_stats(struct qed_dev *cdev,
 		qed_get_protocol_stats_iscsi(cdev, &stats->iscsi_stats);
 		break;
 	default:
-		DP_ERR(cdev, "Invalid protocol type = %d\n", type);
+		DP_VERBOSE(cdev, QED_MSG_SP,
+			   "Invalid protocol type = %d\n", type);
 		return;
 	}
 }
-- 
1.9.3
