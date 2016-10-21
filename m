From: <sudarsana.kalluru@cavium.com>
Subject: [PATCH net 2/7] qede: Do not allow RSS config for 100G devices
Date: Fri, 21 Oct 2016 04:43:40 -0400
Message-ID: <1477039425-31341-3-git-send-email-sudarsana.kalluru@cavium.com>
References: <1477039425-31341-1-git-send-email-sudarsana.kalluru@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Ariel.Elior@cavium.com>,
        <Yuval.Mintz@cavium.com>, <manish.chopra@cavium.com>,
        Sudarsana Reddy Kalluru <sudarsana.kalluru@cavium.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:49048 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S934497AbcJUJaC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Oct 2016 05:30:02 -0400
In-Reply-To: <1477039425-31341-1-git-send-email-sudarsana.kalluru@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sudarsana Reddy Kalluru <sudarsana.kalluru@cavium.com>

RSS configuration is not supported for 100G adapters.

Signed-off-by: Sudarsana Reddy Kalluru <Sudarsana.Kalluru@cavium.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qede/qede_ethtool.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
index 16a1a47..bf04fb9 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
@@ -1055,6 +1055,12 @@ static int qede_set_rxfh(struct net_device *dev, const u32 *indir,
 	struct qede_dev *edev = netdev_priv(dev);
 	int i;
 
+	if (edev->dev_info.common.num_hwfns > 1) {
+		DP_INFO(edev,
+			"RSS configuration is not supported for 100G devices\n");
+		return -EOPNOTSUPP;
+	}
+
 	if (hfunc != ETH_RSS_HASH_NO_CHANGE && hfunc != ETH_RSS_HASH_TOP)
 		return -EOPNOTSUPP;
 
-- 
1.8.3.1
