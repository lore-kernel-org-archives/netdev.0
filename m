From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: [PATCH net-next 5/9] qlge: Added missing case statement to ethtool get_strings.
Date: Tue, 10 Jul 2012 20:57:35 -0400
Message-ID: <1341968259-18931-6-git-send-email-jitendra.kalsaria@qlogic.com>
References: <1341968259-18931-1-git-send-email-jitendra.kalsaria@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com,
	Dept_NX_Linux_NIC_Driver@qlogic.com,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:23996 "HELO linux-zupk.site"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1753597Ab2GKBOi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jul 2012 21:14:38 -0400
In-Reply-To: <1341968259-18931-1-git-send-email-jitendra.kalsaria@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>

Missing case was causing ethtool self test to print garbage
value in extra info section.

Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlge/qlge_ethtool.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_ethtool.c b/drivers/net/ethernet/qlogic/qlge/qlge_ethtool.c
index 3b0912f..4c141da 100644
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
@@ -531,6 +534,8 @@ static void ql_self_test(struct net_device *ndev,
 {
 	struct ql_adapter *qdev = netdev_priv(ndev);
 
+	memset(data, 0, sizeof(u64) * QLGE_TEST_LEN);
+
 	if (netif_running(ndev)) {
 		set_bit(QL_SELFTEST, &qdev->flags);
 		if (eth_test->flags == ETH_TEST_FL_OFFLINE) {
-- 
1.7.1
