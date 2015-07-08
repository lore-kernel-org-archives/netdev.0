From: Vasily Averin <vvs@virtuozzo.com>
Subject: [PATCH] rtnl_lock called twice  in i40e_pci_error_resume()
Date: Wed, 08 Jul 2015 15:04:26 +0300
Message-ID: <559D11CA.6090006@virtuozzo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: intel-wired-lan@lists.osuosl.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Neil Hormann <horman@redhat.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:17330 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753999AbbGHMF3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Jul 2015 08:05:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Vasily Averin <vvs@virtuozzo.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 48a52b3..ef091d4 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -10226,7 +10226,7 @@ static void i40e_pci_error_resume(struct pci_dev *pdev)
 
 	rtnl_lock();
 	i40e_handle_reset_warning(pf);
-	rtnl_lock();
+	rtnl_unlock();
 }
 
 /**
-- 
1.9.1
