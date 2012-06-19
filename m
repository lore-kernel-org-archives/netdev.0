From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [RFC net-next 06/14] Fix intel/igb
Date: Tue, 19 Jun 2012 18:14:00 +0300
Message-ID: <1340118848-30978-7-git-send-email-yuvalmin@broadcom.com>
References: <1340118848-30978-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Yuval Mintz" <yuvalmin@broadcom.com>,
	"Jeff Kirsher" <jeffrey.t.kirsher@intel.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2683 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753908Ab2FSPQe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Jun 2012 11:16:34 -0400
In-Reply-To: <1340118848-30978-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index dd3bfe8..8e7ade5 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -2380,18 +2380,20 @@ static int __devinit igb_sw_init(struct igb_adapter *adapter)
 #endif /* CONFIG_PCI_IOV */
 	switch (hw->mac.type) {
 	case e1000_i210:
-		adapter->rss_queues = min_t(u32, IGB_MAX_RX_QUEUES_I210,
-			num_online_cpus());
+		adapter->rss_queues = IGB_MAX_RX_QUEUES_I210;
 		break;
 	case e1000_i211:
-		adapter->rss_queues = min_t(u32, IGB_MAX_RX_QUEUES_I211,
-			num_online_cpus());
+		adapter->rss_queues = IGB_MAX_RX_QUEUES_I211;
 		break;
 	default:
-		adapter->rss_queues = min_t(u32, IGB_MAX_RX_QUEUES,
-		num_online_cpus());
+		adapter->rss_queues = IGB_MAX_RX_QUEUES;
 		break;
 	}
+
+	adapter->rss_queues = min_t(u32, adapter->rss_queues,
+				    min_t(u32, num_online_cpus(),
+					  DEFAULT_MAX_NUM_RSS_QUEUES));
+
 	/* i350 cannot do RSS and SR-IOV at the same time */
 	if (hw->mac.type == e1000_i350 && adapter->vfs_allocated_count)
 		adapter->rss_queues = 1;
-- 
1.7.9.rc2
