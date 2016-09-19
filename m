From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net] cxgb4/cxgb4vf: Allocate more queues for 100G adapter
Date: Mon, 19 Sep 2016 13:32:46 +0530
Message-ID: <1474272166-30147-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
        Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:63334 "EHLO
        stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751914AbcISH5a (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 03:57:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We were missing check for 100G while checking port speed, which lead to
less number of queues getting allocated for 100G and leading to low
throughput. Adding the missing check for both NIC and vNIC driver.

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    | 3 ++-
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c         | 2 +-
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h | 3 ++-
 3 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index c762a8c8c954..a8e4580f0440 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -4308,7 +4308,8 @@ static const struct pci_error_handlers cxgb4_eeh = {
 static inline bool is_x_10g_port(const struct link_config *lc)
 {
 	return (lc->supported & FW_PORT_CAP_SPEED_10G) != 0 ||
-	       (lc->supported & FW_PORT_CAP_SPEED_40G) != 0;
+	       (lc->supported & FW_PORT_CAP_SPEED_40G) != 0 ||
+	       (lc->supported & FW_PORT_CAP_SPEED_100G) != 0;
 }
 
 static inline void init_rspq(struct adapter *adap, struct sge_rspq *q,
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index dc92c80a75f4..37885223347d 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -3628,7 +3628,7 @@ void t4_ulprx_read_la(struct adapter *adap, u32 *la_buf)
 
 #define ADVERT_MASK (FW_PORT_CAP_SPEED_100M | FW_PORT_CAP_SPEED_1G |\
 		     FW_PORT_CAP_SPEED_10G | FW_PORT_CAP_SPEED_40G | \
-		     FW_PORT_CAP_ANEG)
+		     FW_PORT_CAP_SPEED_100G | FW_PORT_CAP_ANEG)
 
 /**
  *	t4_link_l1cfg - apply link configuration to MAC/PHY
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h
index 8ee541431e8b..903c0584c6c4 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h
@@ -274,7 +274,8 @@ static inline bool is_10g_port(const struct link_config *lc)
 static inline bool is_x_10g_port(const struct link_config *lc)
 {
 	return (lc->supported & FW_PORT_CAP_SPEED_10G) != 0 ||
-		(lc->supported & FW_PORT_CAP_SPEED_40G) != 0;
+		(lc->supported & FW_PORT_CAP_SPEED_40G) != 0 ||
+		(lc->supported & FW_PORT_CAP_SPEED_100G) != 0;
 }
 
 static inline unsigned int core_ticks_per_usec(const struct adapter *adapter)
-- 
2.3.4
