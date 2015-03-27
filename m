From: Varun Prakash <varun@chelsio.com>
Subject: [PATCH net-next 3/3] cxgb4: enable RSS for FCoE frames
Date: Fri, 27 Mar 2015 20:29:39 +0530
Message-ID: <f2eb8941393bca22d200c3f053e4b0023328d8ad.1427467737.git.varun@chelsio.com>
References: <cover.1427467737.git.varun@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, anish@chelsio.com,
	hariprasad@chelsio.com, praveenm@chelsio.com, varun@chelsio.com
To: netdev@vger.kernel.org, linux-scsi@vger.kernel.org
Return-path: <linux-scsi-owner@vger.kernel.org>
In-Reply-To: <cover.1427467737.git.varun@chelsio.com>
In-Reply-To: <cover.1427467737.git.varun@chelsio.com>
References: <cover.1427467737.git.varun@chelsio.com>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Varun Prakash <varun@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c |    8 ++++++++
 drivers/net/ethernet/chelsio/cxgb4/t4_regs.h    |    8 ++++++++
 2 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index d235d3b..be39946 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -918,6 +918,9 @@ static int write_rss(const struct port_info *pi, const u16 *queues)
 static int setup_rss(struct adapter *adap)
 {
 	int i, err;
+#ifdef CONFIG_CHELSIO_T4_FCOE
+	u32 rss_config;
+#endif
 
 	for_each_port(adap, i) {
 		const struct port_info *pi = adap2pinfo(adap, i);
@@ -926,6 +929,11 @@ static int setup_rss(struct adapter *adap)
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
index 231a725..57226c5 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_regs.h
@@ -1853,6 +1853,14 @@
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

