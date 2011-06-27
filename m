From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next-2.6 3/3] be2net: fix initialization of vlan_prio_bmap
Date: Mon, 27 Jun 2011 12:11:53 +0530
Message-ID: <9126f0fa-e344-4bf8-afe2-270985b37d75@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sathya Perla <sathya.perla@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:48991 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753762Ab1F0Gle (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2011 02:41:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Initialization of this field to "all priorities" must be done before MCC queue
creation. As soon as the MCC queue is created, an event modifying this value
may be received.

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/benet/be_main.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 2373d39..ae281de 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -2554,6 +2554,9 @@ static int be_setup(struct be_adapter *adapter)
 	if (status != 0)
 		goto tx_qs_destroy;
 
+	/* Allow all priorities by default. A GRP5 evt may modify this */
+	adapter->vlan_prio_bmap = 0xff;
+
 	status = be_mcc_queues_create(adapter);
 	if (status != 0)
 		goto rx_qs_destroy;
@@ -3419,10 +3422,6 @@ static int __devinit be_probe(struct pci_dev *pdev,
 	}
 
 	dev_info(&pdev->dev, "%s port %d\n", nic_name(pdev), adapter->port_num);
-	/* By default all priorities are enabled.
-	 * Needed in case of no GRP5 evt support
-	 */
-	adapter->vlan_prio_bmap = 0xff;
 
 	schedule_delayed_work(&adapter->work, msecs_to_jiffies(100));
 	return 0;
-- 
1.7.4

