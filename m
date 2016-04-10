From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 1/4] qed*: remove version dependency
Date: Sun, 10 Apr 2016 12:42:59 +0300
Message-ID: <1460281382-13656-2-git-send-email-Yuval.Mintz@qlogic.com>
References: <1460281382-13656-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Rahul Verma <rahul.verma@qlogic.com>,
	Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:37914 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752485AbcDJJnL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Apr 2016 05:43:11 -0400
In-Reply-To: <1460281382-13656-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rahul Verma <rahul.verma@qlogic.com>

Inbox drivers don't need versioning scheme in order to guarantee
compatibility, as both qed and qede are compiled from same codebase.

Signed-off-by: Rahul Verma <rahul.verma@qlogic.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qed/qed.h        |  2 --
 drivers/net/ethernet/qlogic/qed/qed_l2.c     |  8 +-------
 drivers/net/ethernet/qlogic/qed/qed_main.c   | 11 -----------
 drivers/net/ethernet/qlogic/qede/qede.h      |  2 --
 drivers/net/ethernet/qlogic/qede/qede_main.c | 11 +----------
 include/linux/qed/qed_eth_if.h               |  2 +-
 include/linux/qed/qed_if.h                   |  9 ---------
 7 files changed, 3 insertions(+), 42 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qed/qed.h b/drivers/net/ethernet/qlogic/qed/qed.h
index fcb8e9b..a3ee9df 100644
--- a/drivers/net/ethernet/qlogic/qed/qed.h
+++ b/drivers/net/ethernet/qlogic/qed/qed.h
@@ -507,6 +507,4 @@ u32 qed_unzip_data(struct qed_hwfn *p_hwfn,
 
 int qed_slowpath_irq_req(struct qed_hwfn *hwfn);
 
-#define QED_ETH_INTERFACE_VERSION       300
-
 #endif /* _QED_H */
diff --git a/drivers/net/ethernet/qlogic/qed/qed_l2.c b/drivers/net/ethernet/qlogic/qed/qed_l2.c
index 3f35c6c..e848d5a 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_l2.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_l2.c
@@ -2043,14 +2043,8 @@ static const struct qed_eth_ops qed_eth_ops_pass = {
 	.get_vport_stats = &qed_get_vport_stats,
 };
 
-const struct qed_eth_ops *qed_get_eth_ops(u32 version)
+const struct qed_eth_ops *qed_get_eth_ops(void)
 {
-	if (version != QED_ETH_INTERFACE_VERSION) {
-		pr_notice("Cannot supply ethtool operations [%08x != %08x]\n",
-			  version, QED_ETH_INTERFACE_VERSION);
-		return NULL;
-	}
-
 	return &qed_eth_ops_pass;
 }
 EXPORT_SYMBOL(qed_get_eth_ops);
diff --git a/drivers/net/ethernet/qlogic/qed/qed_main.c b/drivers/net/ethernet/qlogic/qed/qed_main.c
index 26d40db..c31d485 100644
--- a/drivers/net/ethernet/qlogic/qed/qed_main.c
+++ b/drivers/net/ethernet/qlogic/qed/qed_main.c
@@ -1172,14 +1172,3 @@ const struct qed_common_ops qed_common_ops_pass = {
 	.chain_free = &qed_chain_free,
 	.set_led = &qed_set_led,
 };
-
-u32 qed_get_protocol_version(enum qed_protocol protocol)
-{
-	switch (protocol) {
-	case QED_PROTOCOL_ETH:
-		return QED_ETH_INTERFACE_VERSION;
-	default:
-		return 0;
-	}
-}
-EXPORT_SYMBOL(qed_get_protocol_version);
diff --git a/drivers/net/ethernet/qlogic/qede/qede.h b/drivers/net/ethernet/qlogic/qede/qede.h
index d023251..e0a696a 100644
--- a/drivers/net/ethernet/qlogic/qede/qede.h
+++ b/drivers/net/ethernet/qlogic/qede/qede.h
@@ -32,8 +32,6 @@
 		__stringify(QEDE_REVISION_VERSION) "."		\
 		__stringify(QEDE_ENGINEERING_VERSION)
 
-#define QEDE_ETH_INTERFACE_VERSION	300
-
 #define DRV_MODULE_SYM		qede
 
 struct qede_stats {
diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index 518af32..a55d93e 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -141,19 +141,10 @@ static
 int __init qede_init(void)
 {
 	int ret;
-	u32 qed_ver;
 
 	pr_notice("qede_init: %s\n", version);
 
-	qed_ver = qed_get_protocol_version(QED_PROTOCOL_ETH);
-	if (qed_ver !=  QEDE_ETH_INTERFACE_VERSION) {
-		pr_notice("Version mismatch [%08x != %08x]\n",
-			  qed_ver,
-			  QEDE_ETH_INTERFACE_VERSION);
-		return -EINVAL;
-	}
-
-	qed_ops = qed_get_eth_ops(QEDE_ETH_INTERFACE_VERSION);
+	qed_ops = qed_get_eth_ops();
 	if (!qed_ops) {
 		pr_notice("Failed to get qed ethtool operations\n");
 		return -EINVAL;
diff --git a/include/linux/qed/qed_eth_if.h b/include/linux/qed/qed_eth_if.h
index e1d6983..e00c8db 100644
--- a/include/linux/qed/qed_eth_if.h
+++ b/include/linux/qed/qed_eth_if.h
@@ -167,7 +167,7 @@ struct qed_eth_ops {
 				struct qed_eth_stats *stats);
 };
 
-const struct qed_eth_ops *qed_get_eth_ops(u32 version);
+const struct qed_eth_ops *qed_get_eth_ops(void);
 void qed_put_eth_ops(void);
 
 #endif
diff --git a/include/linux/qed/qed_if.h b/include/linux/qed/qed_if.h
index 1f7599c7..b007011 100644
--- a/include/linux/qed/qed_if.h
+++ b/include/linux/qed/qed_if.h
@@ -271,15 +271,6 @@ struct qed_common_ops {
 		       enum qed_led_mode mode);
 };
 
-/**
- * @brief qed_get_protocol_version
- *
- * @param protocol
- *
- * @return version supported by qed for given protocol driver
- */
-u32 qed_get_protocol_version(enum qed_protocol protocol);
-
 #define MASK_FIELD(_name, _value) \
 	((_value) &= (_name ## _MASK))
 
-- 
1.9.3
