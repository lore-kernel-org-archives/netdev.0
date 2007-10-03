From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 2.6.24 1/3][BNX2]: Add missing napi_disable() in
 bnx2_close().
Date: Tue, 02 Oct 2007 17:23:09 -0700
Message-ID: <1191370989.5961.31.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2090 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751467AbXJBXYK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Oct 2007 19:24:10 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[BNX2]: Add missing napi_disable() in bnx2_close().

bnx2_close() -> bnx2_netif_stop() will not call napi_disable() because
the netif_state is not running in bnx2_close().  To avoid confusion,
we change it to disable interrupt and napi directly in bnx2_close().

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index cd5f1b7..4887c31 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -5212,8 +5212,8 @@ bnx2_close(struct net_device *dev)
 	while (bp->in_reset_task)
 		msleep(1);
 
-	/* This does napi_disable() for us.  */
-	bnx2_netif_stop(bp);
+	bnx2_disable_int_sync(bp);
+	napi_disable(&bp->napi);
 	del_timer_sync(&bp->timer);
 	if (bp->flags & NO_WOL_FLAG)
 		reset_code = BNX2_DRV_MSG_CODE_UNLOAD_LNK_DN;


