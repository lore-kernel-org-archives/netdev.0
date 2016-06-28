From: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>
Subject: [PATCH net-next 2/2] qede: Fix the static checker warnings.
Date: Tue, 28 Jun 2016 02:10:59 -0400
Message-ID: <1467094259-16061-3-git-send-email-sudarsana.kalluru@qlogic.com>
References: <1467094259-16061-1-git-send-email-sudarsana.kalluru@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Yuval.Mintz@qlogic.com>,
	<sudarsana.kalluru@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:48307 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751060AbcF1Gz3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jun 2016 02:55:29 -0400
In-Reply-To: <1467094259-16061-1-git-send-email-sudarsana.kalluru@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Static checker warnings:
drivers/net/ethernet/qlogic/qede/qede_ethtool.c:435 qede_get_coalesce()
warn: passing casted pointer '&coal->rx_coalesce_usecs' to
'edev->ops->common->get_coalesce()' 32 vs 16.

The u32 pointer is being typecasted to u16 which may fail for big-endian
platforms.

Fixes: d552fa84cb35 ("qede: Add support for coalescing config read/update.")
Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>
---
 drivers/net/ethernet/qlogic/qede/qede_ethtool.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
index 6228482..c5c658a 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
@@ -430,11 +430,13 @@ static int qede_get_coalesce(struct net_device *dev,
 			     struct ethtool_coalesce *coal)
 {
 	struct qede_dev *edev = netdev_priv(dev);
+	u16 rxc, txc;
 
 	memset(coal, 0, sizeof(struct ethtool_coalesce));
-	edev->ops->common->get_coalesce(edev->cdev,
-					(u16 *)&coal->rx_coalesce_usecs,
-					(u16 *)&coal->tx_coalesce_usecs);
+	edev->ops->common->get_coalesce(edev->cdev, &rxc, &txc);
+
+	coal->rx_coalesce_usecs = rxc;
+	coal->tx_coalesce_usecs = txc;
 
 	return 0;
 }
-- 
1.8.3.1
