From: Manish Chopra <manish.chopra@qlogic.com>
Subject: [PATCH net 3/4] qlcnic: Remove __QLCNIC_DEV_UP bit check to read TX queues statistics.
Date: Mon, 22 Sep 2014 05:51:52 -0400
Message-ID: <1411379513-26902-4-git-send-email-manish.chopra@qlogic.com>
References: <1411379513-26902-1-git-send-email-manish.chopra@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-GELinuxNICDev@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:33649 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753902AbaIVKZt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2014 06:25:49 -0400
In-Reply-To: <1411379513-26902-1-git-send-email-manish.chopra@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o TX queues stats must be read when queues are allocated regardless
  of interface is up or not.

Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
---
 .../net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c    |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
index 2d77b76..863c445 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_ethtool.c
@@ -1339,7 +1339,7 @@ static void qlcnic_get_ethtool_stats(struct net_device *dev,
 	memset(data, 0, stats->n_stats * sizeof(u64));
 
 	for (ring = 0, index = 0; ring < adapter->drv_tx_rings; ring++) {
-		if (test_bit(__QLCNIC_DEV_UP, &adapter->state)) {
+		if (adapter->is_up == QLCNIC_ADAPTER_UP_MAGIC) {
 			tx_ring = &adapter->tx_ring[ring];
 			data = qlcnic_fill_tx_queue_stats(data, tx_ring);
 			qlcnic_update_stats(adapter);
-- 
1.7.1
