From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: [PATCH net 3/7] qlge: Garbage values shown in extra info during selftest.
Date: Mon,  2 Jul 2012 19:41:50 -0400
Message-ID: <1341272514-5156-4-git-send-email-jitendra.kalsaria@qlogic.com>
References: <1341272514-5156-1-git-send-email-jitendra.kalsaria@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com,
	Dept_NX_Linux_NIC_Driver@qlogic.com,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:43406 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1751107Ab2GECev (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jul 2012 22:34:51 -0400
In-Reply-To: <1341272514-5156-1-git-send-email-jitendra.kalsaria@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>

while running selftest 'ethtool -t' multiple times will get
different values in the 'extra info' section, which was garbage.

Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlge/qlge_ethtool.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_ethtool.c b/drivers/net/ethernet/qlogic/qlge/qlge_ethtool.c
index 98f04d7..31ee6dc 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qlge/qlge_ethtool.c
@@ -248,6 +248,9 @@ static char ql_stats_str_arr[][ETH_GSTRING_LEN] = {
 static void ql_get_strings(struct net_device *dev, u32 stringset, u8 *buf)
 {
 	switch (stringset) {
+	case ETH_SS_TEST:
+		memcpy(buf, *ql_gstrings_test, QLGE_TEST_LEN * ETH_GSTRING_LEN);
+		break;
 	case ETH_SS_STATS:
 		memcpy(buf, ql_stats_str_arr, sizeof(ql_stats_str_arr));
 		break;
@@ -538,6 +541,8 @@ static void ql_self_test(struct net_device *ndev,
 {
 	struct ql_adapter *qdev = netdev_priv(ndev);
 
+	memset(data, 0, sizeof(u64) * QLGE_TEST_LEN);
+
 	if (netif_running(ndev)) {
 		set_bit(QL_SELFTEST, &qdev->flags);
 		if (eth_test->flags == ETH_TEST_FL_OFFLINE) {
-- 
1.7.1
