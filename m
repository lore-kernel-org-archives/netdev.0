From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/17] i40e: rtnl_lock called twice in i40e_pci_error_resume()
Date: Wed, 30 Sep 2015 05:52:26 -0700
Message-ID: <1443617561-40490-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1443617561-40490-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Vasily Averin <vvs@virtuozzo.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:48753 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755360AbbI3Mwn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Sep 2015 08:52:43 -0400
In-Reply-To: <1443617561-40490-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasily Averin <vvs@virtuozzo.com>

Signed-off-by: Vasily Averin <vvs@virtuozzo.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 52e58f30..613da51 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -10537,7 +10537,7 @@ static void i40e_pci_error_resume(struct pci_dev *pdev)
 
 	rtnl_lock();
 	i40e_handle_reset_warning(pf);
-	rtnl_lock();
+	rtnl_unlock();
 }
 
 /**
-- 
2.4.3
