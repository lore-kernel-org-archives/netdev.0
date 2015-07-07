From: Vasily Averin <vvs@virtuozzo.com>
Subject: [PATCH 2/3] missing rtnl_unlock in igb_sriov_reinit()
Date: Tue, 07 Jul 2015 18:53:45 +0300
Message-ID: <559BF609.4020705@virtuozzo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: intel-wired-lan@lists.osuosl.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Todd Fujinaka <todd.fujinaka@intel.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:35851 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758245AbbGGPyu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jul 2015 11:54:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Vasily Averin <vvs@virtuozzo.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 2f70a9b..5881458 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -7538,6 +7538,7 @@ static int igb_sriov_reinit(struct pci_dev *dev)
 	igb_init_queue_configuration(adapter);
 
 	if (igb_init_interrupt_scheme(adapter, true)) {
+		rtnl_unlock();
 		dev_err(&pdev->dev, "Unable to allocate memory for queues\n");
 		return -ENOMEM;
 	}
-- 
1.9.1
