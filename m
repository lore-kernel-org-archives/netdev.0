From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 4/7] be2net: fix reporting number of actual rx queues
Date: Wed, 6 Jun 2012 11:07:20 +0530
Message-ID: <3b708c41-4732-4ff4-8e21-bce0a1b07dbe@exht1.ad.emulex.com>
References: <1338961043-26820-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sathya Perla <sathya.perla@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:2015 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753281Ab2FFFwa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2012 01:52:30 -0400
In-Reply-To: <1338961043-26820-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 695c3cf..3aa478f 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -1890,6 +1890,12 @@ static int be_rx_cqs_create(struct be_adapter *adapter)
 	 */
 	adapter->num_rx_qs = (num_irqs(adapter) > 1) ?
 				num_irqs(adapter) + 1 : 1;
+	if (adapter->num_rx_qs != MAX_RX_QS) {
+		rtnl_lock();
+		netif_set_real_num_rx_queues(adapter->netdev,
+					     adapter->num_rx_qs);
+		rtnl_unlock();
+	}
 
 	adapter->big_page_size = (1 << get_order(rx_frag_size)) * PAGE_SIZE;
 	for_all_rx_queues(adapter, rxo, i) {
@@ -3740,7 +3746,7 @@ static int __devinit be_probe(struct pci_dev *pdev,
 		goto disable_dev;
 	pci_set_master(pdev);
 
-	netdev = alloc_etherdev_mq(sizeof(struct be_adapter), MAX_TX_QS);
+	netdev = alloc_etherdev_mqs(sizeof(*adapter), MAX_TX_QS, MAX_RX_QS);
 	if (netdev == NULL) {
 		status = -ENOMEM;
 		goto rel_reg;
-- 
1.7.4
