From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: [PATCH net 1/3] qlge: Fix ethtool statistics
Date: Thu, 5 Dec 2013 18:11:22 -0500
Message-ID: <1386285084-25250-2-git-send-email-jitendra.kalsaria@qlogic.com>
References: <1386285084-25250-1-git-send-email-jitendra.kalsaria@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <ron.mercer@qlogic.com>,
	<Dept-HSGLinuxNICDev@qlogic.com>,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:37095 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756030Ab3LEXoE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 18:44:04 -0500
In-Reply-To: <1386285084-25250-1-git-send-email-jitendra.kalsaria@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>

o Receive mac error stat was getting overwritten by other stats.

Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlge/qlge_ethtool.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_ethtool.c b/drivers/net/ethernet/qlogic/qlge/qlge_ethtool.c
index 0780e03..8dee1be 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qlge/qlge_ethtool.c
@@ -181,6 +181,7 @@ static const char ql_gstrings_test[][ETH_GSTRING_LEN] = {
 };
 #define QLGE_TEST_LEN (sizeof(ql_gstrings_test) / ETH_GSTRING_LEN)
 #define QLGE_STATS_LEN ARRAY_SIZE(ql_gstrings_stats)
+#define QLGE_RCV_MAC_ERR_STATS	7
 
 static int ql_update_ring_coalescing(struct ql_adapter *qdev)
 {
@@ -280,6 +281,9 @@ static void ql_update_stats(struct ql_adapter *qdev)
 		iter++;
 	}
 
+	/* Update receive mac error statistics */
+	iter += QLGE_RCV_MAC_ERR_STATS;
+
 	/*
 	 * Get Per-priority TX pause frame counter statistics.
 	 */
-- 
1.7.6.rc1.1.g2c162b
