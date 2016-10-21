From: <sudarsana.kalluru@cavium.com>
Subject: [PATCH net 1/7] qede: get_channels() need to populate max tx/rx coalesce values
Date: Fri, 21 Oct 2016 04:43:39 -0400
Message-ID: <1477039425-31341-2-git-send-email-sudarsana.kalluru@cavium.com>
References: <1477039425-31341-1-git-send-email-sudarsana.kalluru@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Ariel.Elior@cavium.com>,
        <Yuval.Mintz@cavium.com>, <manish.chopra@cavium.com>,
        Sudarsana Reddy Kalluru <sudarsana.kalluru@cavium.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:49042 "EHLO
        mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S934187AbcJUJaB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Oct 2016 05:30:01 -0400
In-Reply-To: <1477039425-31341-1-git-send-email-sudarsana.kalluru@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sudarsana Reddy Kalluru <sudarsana.kalluru@cavium.com>

Recent changes in kernel ethtool implementation requires the driver
callback for get_channels() has to populate the values for max tx/rx
coalesce fields.

Signed-off-by: Sudarsana Reddy Kalluru <Sudarsana.Kalluru@cavium.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qede/qede_ethtool.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
index 25a9b29..16a1a47 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
@@ -756,6 +756,8 @@ static void qede_get_channels(struct net_device *dev,
 	struct qede_dev *edev = netdev_priv(dev);
 
 	channels->max_combined = QEDE_MAX_RSS_CNT(edev);
+	channels->max_rx = QEDE_MAX_RSS_CNT(edev);
+	channels->max_tx = QEDE_MAX_RSS_CNT(edev);
 	channels->combined_count = QEDE_QUEUE_CNT(edev) - edev->fp_num_tx -
 					edev->fp_num_rx;
 	channels->tx_count = edev->fp_num_tx;
-- 
1.8.3.1
