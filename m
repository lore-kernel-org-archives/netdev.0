From: wenxiong@linux.vnet.ibm.com
Subject: [PATCH V3 1/2] bnx2x: Adapter not recovery from EEH error injection
Date: Tue, 03 Jun 2014 14:14:45 -0500
Message-ID: <20140603191538.609393466@linux.vnet.ibm.com>
References: <20140603191444.269911990@linux.vnet.ibm.com>
Cc: ariel.elior@qlogic.com, netdev@vger.kernel.org,
	Wen Xiong <wenxiong@linux.vnet.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from [32.97.110.57] ([32.97.110.57]:33236 "HELO
	jupiter1-lp2.austin.ibm.com" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with SMTP id S1753727AbaFCTSy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2014 15:18:54 -0400
Content-Disposition: inline; filename=bnx2x_eeh_fix
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When injecting EEH error to bnx2x adapter, adapter couldn't be recovery
and caused recursive EEH errors. The patch fixes the issue.

Signed-off-by: Wen Xiong <wenxiong@linux.vnet.ibm.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

Index: b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
===================================================================
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c	2014-05-22 18:42:48.000000000 -0500
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c	2014-05-22 18:44:36.757765539 -0500
@@ -13279,8 +13279,8 @@ static int bnx2x_eeh_nic_unload(struct b
 	netdev_reset_tc(bp->dev);
 
 	del_timer_sync(&bp->timer);
-	cancel_delayed_work(&bp->sp_task);
-	cancel_delayed_work(&bp->period_task);
+	cancel_delayed_work_sync(&bp->sp_task);
+	cancel_delayed_work_sync(&bp->period_task);
 
 	spin_lock_bh(&bp->stats_lock);
 	bp->stats_state = STATS_STATE_DISABLED;

-- 
