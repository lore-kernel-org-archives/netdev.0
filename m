From: Vasily Averin <vvs@virtuozzo.com>
Subject: [PATCH 1/3] missing rtnl_unlock in i40evf_resume()
Date: Tue, 07 Jul 2015 18:53:38 +0300
Message-ID: <559BF602.406@virtuozzo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: intel-wired-lan@lists.osuosl.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:17798 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758008AbbGGPym (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Jul 2015 11:54:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Vasily Averin <vvs@virtuozzo.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 4ab4ebb..dd6a428 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -2402,6 +2402,7 @@ static int i40evf_resume(struct pci_dev *pdev)
 	rtnl_lock();
 	err = i40evf_set_interrupt_capability(adapter);
 	if (err) {
+		rtnl_unlock();
 		dev_err(&pdev->dev, "Cannot enable MSI-X interrupts.\n");
 		return err;
 	}
-- 
1.9.1
