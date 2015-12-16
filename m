From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 3/4] cxgb4: Use t4_mgmt_tx() API for sending write l2t request ctrl packets.
Date: Wed, 16 Dec 2015 13:16:27 +0530
Message-ID: <1450251988-9246-4-git-send-email-hariprasad@chelsio.com>
References: <1450251988-9246-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:3545 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932890AbbLPHp3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Dec 2015 02:45:29 -0500
In-Reply-To: <1450251988-9246-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Based on original work by Michael Werner <werner@chelsio.com>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/l2t.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/l2t.c b/drivers/net/ethernet/chelsio/cxgb4/l2t.c
index f7e3775..0eab828 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/l2t.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/l2t.c
@@ -161,8 +161,7 @@ static int write_l2e(struct adapter *adap, struct l2t_entry *e, int sync)
 		memcpy(e->dmac, e->neigh->ha, sizeof(e->dmac));
 	memcpy(req->dst_mac, e->dmac, sizeof(req->dst_mac));
 
-	set_wr_txq(skb, CPL_PRIORITY_CONTROL, 0);
-	t4_ofld_send(adap, skb);
+	t4_mgmt_tx(adap, skb);
 
 	if (sync && e->state != L2T_STATE_SWITCHING)
 		e->state = L2T_STATE_SYNC_WRITE;
-- 
2.3.4
