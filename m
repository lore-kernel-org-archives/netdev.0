From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 3/5] igb: Fix Tx hangs seen when loading igb with
	max_vfs > 7.
Date: Thu, 01 Jul 2010 16:38:40 -0700
Message-ID: <20100701233838.16171.90269.stgit@localhost.localdomain>
References: <20100701233733.16171.4629.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Emil Tantilov <emil.s.tantilov@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta09.emeryville.ca.mail.comcast.net ([76.96.30.96]:50578 "EHLO
	qmta09.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753101Ab0GAXi7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Jul 2010 19:38:59 -0400
In-Reply-To: <20100701233733.16171.4629.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

Check the value of max_vfs at the time of assignment of vfs_allocated_count.

The previous check in igb_probe_vfs was too late as by that time the rx/tx
rings were initialized with the wrong offset.

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index e79689e..d811462 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -2091,9 +2091,6 @@ static void __devinit igb_probe_vfs(struct igb_adapter * adapter)
 #ifdef CONFIG_PCI_IOV
 	struct pci_dev *pdev = adapter->pdev;
 
-	if (adapter->vfs_allocated_count > 7)
-		adapter->vfs_allocated_count = 7;
-
 	if (adapter->vfs_allocated_count) {
 		adapter->vf_data = kcalloc(adapter->vfs_allocated_count,
 		                           sizeof(struct vf_data_storage),
@@ -2258,7 +2255,7 @@ static int __devinit igb_sw_init(struct igb_adapter *adapter)
 
 #ifdef CONFIG_PCI_IOV
 	if (hw->mac.type == e1000_82576)
-		adapter->vfs_allocated_count = max_vfs;
+		adapter->vfs_allocated_count = (max_vfs > 7) ? 7 : max_vfs;
 
 #endif /* CONFIG_PCI_IOV */
 	adapter->rss_queues = min_t(u32, IGB_MAX_RX_QUEUES, num_online_cpus());

