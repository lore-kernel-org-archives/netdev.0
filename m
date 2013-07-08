From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Subject: [PATCH] drivers/net: igb: release rtnl_lock on error path
Date: Mon, 08 Jul 2013 11:22:57 +0400
Message-ID: <20130708072257.20564.36904.stgit@zurg>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This adds missing rtnl_unlock()

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Cc: e1000-devel@lists.sourceforge.net
---
 drivers/net/ethernet/intel/igb/igb_main.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 64cbe0d..86ac29d 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -7235,6 +7235,7 @@ static int igb_sriov_reinit(struct pci_dev *dev)
 	igb_init_queue_configuration(adapter);
 
 	if (igb_init_interrupt_scheme(adapter, true)) {
+		rtnl_unlock();
 		dev_err(&pdev->dev, "Unable to allocate memory for queues\n");
 		return -ENOMEM;
 	}
