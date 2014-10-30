From: Anish Bhatt <anish@chelsio.com>
Subject: [PATCH net] cxgb4 : Fix missing initialization of win0_lock
Date: Wed, 29 Oct 2014 17:54:03 -0700
Message-ID: <1414630443-6412-1-git-send-email-anish@chelsio.com>
Cc: davem@davemloft.net, hariprasad@chelsio.com, leedom@chelsio.com,
	Anish Bhatt <anish@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 99-65-72-227.uvs.sntcca.sbcglobal.net ([99.65.72.227]:43818
	"EHLO stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756773AbaJ3Ay0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2014 20:54:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

win0_lock was being used un-initialized, resulting in warning traces
being seen when lock debugging is enabled (and just wrong)

Fixes : fc5ab0209650 ('cxgb4: Replaced the backdoor mechanism to access the HW
 memory with PCIe Window method')

Signed-off-by: Anish Bhatt <anish@chelsio.com>
Signed-off-by: Casey Leedom <leedom@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 97683c1..8520d55 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -6614,6 +6614,7 @@ static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	spin_lock_init(&adapter->stats_lock);
 	spin_lock_init(&adapter->tid_release_lock);
+	spin_lock_init(&adapter->win0_lock);
 
 	INIT_WORK(&adapter->tid_release_task, process_tid_release_list);
 	INIT_WORK(&adapter->db_full_task, process_db_full);
-- 
2.1.2
