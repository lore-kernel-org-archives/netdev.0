From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net 4/6] qede: Reset statistics on explicit down
Date: Wed, 27 Jul 2016 14:45:22 +0300
Message-ID: <1469619924-12806-5-git-send-email-Yuval.Mintz@qlogic.com>
References: <1469619924-12806-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:59990 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755310AbcG0Lpm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jul 2016 07:45:42 -0400
In-Reply-To: <1469619924-12806-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adding the necessary logic to prevet statistics reset
on inner-reload introduced a bug, and now statistics
are reset only when re-probing the driver.

Fixes: a0d26d5a4fc8e ("qed*: Don't reset statistics on inner reload")
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qede/qede_main.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index 8fe3cc1..14f79c3 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -3256,6 +3256,7 @@ static int qede_start_queues(struct qede_dev *edev, bool clear_stats)
 	start.vport_id = 0;
 	start.drop_ttl0 = true;
 	start.remove_inner_vlan = vlan_removal_en;
+	start.clear_stats = clear_stats;
 
 	rc = edev->ops->vport_start(cdev, &start);
 
-- 
1.9.3
