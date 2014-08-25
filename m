From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 3/5] bnx2x: VF clean statistics
Date: Mon, 25 Aug 2014 17:48:31 +0300
Message-ID: <1408978113-27902-4-git-send-email-Yuval.Mintz@qlogic.com>
References: <1408978113-27902-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:30880 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932963AbaHYOsw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2014 10:48:52 -0400
In-Reply-To: <1408978113-27902-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

During statistics initialization of a VF we need to clean its statistics.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
index e1c8193..d160829 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
@@ -1629,6 +1629,11 @@ void bnx2x_stats_init(struct bnx2x *bp)
 	int /*abs*/port = BP_PORT(bp);
 	int mb_idx = BP_FW_MB_IDX(bp);
 
+	if (IS_VF(bp)) {
+		bnx2x_memset_stats(bp);
+		return;
+	}
+
 	bp->stats_pending = 0;
 	bp->executer_idx = 0;
 	bp->stats_counter = 0;
-- 
1.8.3.1
