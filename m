From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 2/2] bnx2x: Show port statistics in Multi-function
Date: Thu, 19 Nov 2015 17:04:36 +0200
Message-ID: <1447945476-26945-3-git-send-email-Yuval.Mintz@qlogic.com>
References: <1447945476-26945-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:27885 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934331AbbKSPEw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 10:04:52 -0500
In-Reply-To: <1447945476-26945-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Today, port statistics are being presented when using `ethool -S' only
for single-function devices, but there are some port statistics which are
crucial for analyzing bottle-necks. E.g., HW Rx discards due to lack of
buffer space [when device isn't handling ingress traffic fast enough].

Judging the pros and cons, it was decided that in-order to better support
automatic dump-gathering tools, bnx2x should no longer hide those stats.
This leaves only VFs lacking the port statistics.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index 1dc77ac..a3ce9f2 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -3069,9 +3069,7 @@ static void bnx2x_self_test(struct net_device *dev,
 #define IS_PORT_STAT(i) \
 	((bnx2x_stats_arr[i].flags & STATS_FLAGS_BOTH) == STATS_FLAGS_PORT)
 #define IS_FUNC_STAT(i)		(bnx2x_stats_arr[i].flags & STATS_FLAGS_FUNC)
-#define HIDE_PORT_STAT(bp) \
-		((IS_MF(bp) && !(bp->msg_enable & BNX2X_MSG_STATS)) || \
-		 IS_VF(bp))
+#define HIDE_PORT_STAT(bp)	IS_VF(bp)
 
 /* ethtool statistics are displayed for all regular ethernet queues and the
  * fcoe L2 queue if not disabled
-- 
1.9.3
