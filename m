From: Varun Prakash <varun@chelsio.com>
Subject: [PATCH net-next v2 4/4] cxgb4: enable RSS for FCoE frames
Date: Mon, 13 Apr 2015 19:34:26 +0530
Message-ID: <2d7fba63fc47db25362b3f255d3acd1ae340f7f7.1428930614.git.varun@chelsio.com>
References: <cover.1428930614.git.varun@chelsio.com>
Cc: davem@davemloft.net, JBottomley@parallels.com,
	roland@purestorage.com, leedom@chelsio.com, anish@chelsio.com,
	hariprasad@chelsio.com, swise@opengridcomputing.com,
	kxie@chelsio.com, praveenm@chelsio.com, kumaras@chelsio.com,
	varun@chelsio.com
To: netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	linux-rdma@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:24105 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754086AbbDMOF1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2015 10:05:27 -0400
In-Reply-To: <cover.1428930614.git.varun@chelsio.com>
In-Reply-To: <cover.1428930614.git.varun@chelsio.com>
References: <cover.1428930614.git.varun@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Varun Prakash <varun@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |    8 ++++++++
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h    |    8 ++++++++
 2 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 95e7527..606aa5a 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -910,6 +910,9 @@ int cxgb4_write_rss(const struct port_info *pi, const u16 *queues)
 static int setup_rss(struct adapter *adap)
 {
 	int i, err;
+#ifdef CONFIG_CHELSIO_T4_FCOE
+	u32 rss_config;
+#endif
 
 	for_each_port(adap, i) {
 		const struct port_info *pi = adap2pinfo(adap, i);
@@ -918,6 +921,11 @@ static int setup_rss(struct adapter *adap)
 		if (err)
 			return err;
 	}
+#ifdef CONFIG_CHELSIO_T4_FCOE
+	rss_config = t4_read_reg(adap, TP_RSS_CONFIG_A);
+	rss_config |= TNLFCOEEN_F | TNLFCOEMODE_F;
+	t4_write_reg(adap, TP_RSS_CONFIG_A, rss_config);
+#endif
 	return 0;
 }
 
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
index 326674b..3e10c99 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
@@ -1856,6 +1856,14 @@
 #define DISABLE_V(x) ((x) << DISABLE_S)
 #define DISABLE_F    DISABLE_V(1U)
 
+#define TNLFCOEMODE_S    23
+#define TNLFCOEMODE_V(x) ((x) << TNLFCOEMODE_S)
+#define TNLFCOEMODE_F    TNLFCOEMODE_V(1U)
+
+#define TNLFCOEEN_S    21
+#define TNLFCOEEN_V(x) ((x) << TNLFCOEEN_S)
+#define TNLFCOEEN_F    TNLFCOEEN_V(1U)
+
 #define TP_RSS_CONFIG_TNL_A 0x7df4
 
 #define MASKSIZE_S    28
-- 
1.7.1
