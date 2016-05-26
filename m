From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net 3/8] qede: Don't expose self-test for VFs
Date: Thu, 26 May 2016 11:01:19 +0300
Message-ID: <1464249684-976-4-git-send-email-Yuval.Mintz@qlogic.com>
References: <1464249684-976-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:32771 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753202AbcEZIBm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 May 2016 04:01:42 -0400
In-Reply-To: <1464249684-976-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

PFs and VFs differ in their registered ethtool operations,
but they're using a common function for get_sset_count().
As a result, `ethtool -i' for a VF would indicate it supports
selftest, although that's not the case.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qede/qede_ethtool.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
index 1bc7535..ad3cae3 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
@@ -230,7 +230,10 @@ static int qede_get_sset_count(struct net_device *dev, int stringset)
 	case ETH_SS_PRIV_FLAGS:
 		return QEDE_PRI_FLAG_LEN;
 	case ETH_SS_TEST:
-		return QEDE_ETHTOOL_TEST_MAX;
+		if (!IS_VF(edev))
+			return QEDE_ETHTOOL_TEST_MAX;
+		else
+			return 0;
 	default:
 		DP_VERBOSE(edev, QED_MSG_DEBUG,
 			   "Unsupported stringset 0x%08x\n", stringset);
-- 
1.9.3
