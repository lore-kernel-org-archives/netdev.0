From: "Vladislav Zolotarov" <vladz@broadcom.com>
Subject: [PATCH net-2.6 4/5] bnx2x: Fix the race on bp->stats_pending.
Date: Sun, 9 Jan 2011 14:20:34 +0200
Message-ID: <1294575634.31551.18.camel@lb-tlvb-vladz>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "netdev list" <netdev@vger.kernel.org>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "Dave Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1833 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751766Ab1AIMUm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Jan 2011 07:20:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix the race on bp->stats_pending between the timer and a LINK_UP event
handler.

Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_stats.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_stats.c b/drivers/net/bnx2x/bnx2x_stats.c
index 4733c83..0df483d 100644
--- a/drivers/net/bnx2x/bnx2x_stats.c
+++ b/drivers/net/bnx2x/bnx2x_stats.c
@@ -158,6 +158,11 @@ static void bnx2x_storm_stats_post(struct bnx2x *bp)
 
 		spin_lock_bh(&bp->stats_lock);
 
+		if (bp->stats_pending) {
+			spin_unlock_bh(&bp->stats_lock);
+			return;
+		}
+
 		ramrod_data.drv_counter = bp->stats_counter++;
 		ramrod_data.collect_port = bp->port.pmf ? 1 : 0;
 		for_each_queue(bp, i)
-- 
1.7.0.4




