From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next] cxgb4: remove unused fn to enable/disable db coalescing
Date: Mon,  1 Jun 2015 20:07:41 +0530
Message-ID: <1433169461-19888-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:18601 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751468AbbFAJYb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2015 05:24:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove unused function cxgb4_enable_db_coalescing() and
cxgb4_disable_db_coalescing()

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 19 -------------------
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h  |  2 --
 2 files changed, 21 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 4f69b52..974b27c 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -2069,25 +2069,6 @@ out:
 }
 EXPORT_SYMBOL(cxgb4_sync_txq_pidx);
 
-void cxgb4_disable_db_coalescing(struct net_device *dev)
-{
-	struct adapter *adap;
-
-	adap = netdev2adap(dev);
-	t4_set_reg_field(adap, SGE_DOORBELL_CONTROL_A, NOCOALESCE_F,
-			 NOCOALESCE_F);
-}
-EXPORT_SYMBOL(cxgb4_disable_db_coalescing);
-
-void cxgb4_enable_db_coalescing(struct net_device *dev)
-{
-	struct adapter *adap;
-
-	adap = netdev2adap(dev);
-	t4_set_reg_field(adap, SGE_DOORBELL_CONTROL_A, NOCOALESCE_F, 0);
-}
-EXPORT_SYMBOL(cxgb4_enable_db_coalescing);
-
 int cxgb4_read_tpte(struct net_device *dev, u32 stag, __be32 *tpte)
 {
 	struct adapter *adap;
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
index df34293..14e8110 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
@@ -298,8 +298,6 @@ struct sk_buff *cxgb4_pktgl_to_skb(const struct pkt_gl *gl,
 				   unsigned int skb_len, unsigned int pull_len);
 int cxgb4_sync_txq_pidx(struct net_device *dev, u16 qid, u16 pidx, u16 size);
 int cxgb4_flush_eq_cache(struct net_device *dev);
-void cxgb4_disable_db_coalescing(struct net_device *dev);
-void cxgb4_enable_db_coalescing(struct net_device *dev);
 int cxgb4_read_tpte(struct net_device *dev, u32 stag, __be32 *tpte);
 u64 cxgb4_read_sge_timestamp(struct net_device *dev);
 
-- 
2.3.4
