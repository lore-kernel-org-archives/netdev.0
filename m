From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH net 1/2] bna: add missing per queue ethtool stat
Date: Thu, 15 Sep 2016 22:47:51 +0200
Message-ID: <1473972472-29681-1-git-send-email-ivecera@redhat.com>
Cc: jarod@redhat.com, rasesh.mody@qlogic.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:56992 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750717AbcIOUrz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 15 Sep 2016 16:47:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit ba5ca784 "bna: check for dma mapping errors" added besides other
things a statistic that counts number of DMA buffer mapping failures
per each Rx queue. This counter is not included in ethtool stats output.

Fixes: ba5ca784 "bna: check for dma mapping errors"
Signed-off-by: Ivan Vecera <ivecera@redhat.com>
---
 drivers/net/ethernet/brocade/bna/bnad_ethtool.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/brocade/bna/bnad_ethtool.c b/drivers/net/ethernet/brocade/bna/bnad_ethtool.c
index 0e4fdc3..5671353 100644
--- a/drivers/net/ethernet/brocade/bna/bnad_ethtool.c
+++ b/drivers/net/ethernet/brocade/bna/bnad_ethtool.c
@@ -31,7 +31,7 @@
 #define BNAD_NUM_TXF_COUNTERS 12
 #define BNAD_NUM_RXF_COUNTERS 10
 #define BNAD_NUM_CQ_COUNTERS (3 + 5)
-#define BNAD_NUM_RXQ_COUNTERS 6
+#define BNAD_NUM_RXQ_COUNTERS 7
 #define BNAD_NUM_TXQ_COUNTERS 5
 
 #define BNAD_ETHTOOL_STATS_NUM						\
@@ -658,6 +658,8 @@ bnad_get_strings(struct net_device *netdev, u32 stringset, u8 *string)
 				string += ETH_GSTRING_LEN;
 				sprintf(string, "rxq%d_allocbuf_failed", q_num);
 				string += ETH_GSTRING_LEN;
+				sprintf(string, "rxq%d_mapbuf_failed", q_num);
+				string += ETH_GSTRING_LEN;
 				sprintf(string, "rxq%d_producer_index", q_num);
 				string += ETH_GSTRING_LEN;
 				sprintf(string, "rxq%d_consumer_index", q_num);
@@ -678,6 +680,9 @@ bnad_get_strings(struct net_device *netdev, u32 stringset, u8 *string)
 					sprintf(string, "rxq%d_allocbuf_failed",
 								q_num);
 					string += ETH_GSTRING_LEN;
+					sprintf(string, "rxq%d_mapbuf_failed",
+						q_num);
+					string += ETH_GSTRING_LEN;
 					sprintf(string, "rxq%d_producer_index",
 								q_num);
 					string += ETH_GSTRING_LEN;
-- 
2.7.3
