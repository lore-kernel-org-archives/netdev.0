From: Himanshu Madhani <himanshu.madhani@qlogic.com>
Subject: [PATCH net v2 4/8] qlcnic: Fix TSS/RSS validation for 83xx/84xx series adapter.
Date: Mon, 16 Dec 2013 15:36:59 -0500
Message-ID: <6d826af88ec034a193b23e46b3ae8ab8b60892a6.1387256276.git.himanshu.madhani@qlogic.com>
References: <cover.1387256276.git.himanshu.madhani@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Himanshu Madhani <himanshu.madhani@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:57642 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751654Ab3LPVJv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 16:09:51 -0500
In-Reply-To: <cover.1387256276.git.himanshu.madhani@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Himanshu Madhani <himanshu.madhani@qlogic.com>

o Current code was not allowing the user to configure more
  than one Tx ring using ethtool for 83xx/84xx adapter.
  This regression was introduced by commit id
  18afc102fdcb95d6c7d57f2967a06f2f8fe3ba4c ("qlcnic: Enable
  multiple Tx queue support for 83xx/84xx Series adapter.")

Signed-off-by: Himanshu Madhani <himanshu.madhani@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c | 11 +----------
 1 file changed, 1 insertion(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
index 78f5e81..e3be276 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
@@ -680,21 +680,12 @@ static int qlcnic_validate_ring_count(struct qlcnic_adapter *adapter,
 	}
 
 	 if (tx_ring != 0) {
-		if (qlcnic_82xx_check(adapter) &&
-		    (tx_ring > adapter->max_tx_rings)) {
+		if (tx_ring > adapter->max_tx_rings) {
 			netdev_err(adapter->netdev,
 				   "Invalid ring count, Tx ring count %d should not be greater than max %d driver Tx rings.\n",
 				   tx_ring, adapter->max_tx_rings);
 			return -EINVAL;
 		}
-
-		if (qlcnic_83xx_check(adapter) &&
-		    (tx_ring > QLCNIC_SINGLE_RING)) {
-			netdev_err(adapter->netdev,
-				   "Invalid ring count, Tx ring count %d should not be greater than %d driver Tx rings.\n",
-				   tx_ring, QLCNIC_SINGLE_RING);
-			 return -EINVAL;
-		}
 	}
 
 	return 0;
-- 
1.8.1.4
