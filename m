From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 15/15] i40e: use eth_platform_get_mac_address()
Date: Wed, 17 Feb 2016 09:51:46 -0800
Message-ID: <1455731506-62165-16-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1455731506-62165-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:17063 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1422654AbcBQRvx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2016 12:51:53 -0500
In-Reply-To: <1455731506-62165-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>

This commit converts commit b499ffb0a22c ("i40e: Look up MAC address in
Open Firmware or IDPROM") to use eth_platform_get_mac_address()
added by commit c7f5d105495a ("net: Add eth_platform_get_mac_address()
helper.")

Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 19 +------------------
 1 file changed, 1 insertion(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index f6d61cc..04417e6 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -28,11 +28,6 @@
 #include <linux/of_net.h>
 #include <linux/pci.h>
 
-#ifdef CONFIG_SPARC
-#include <asm/idprom.h>
-#include <asm/prom.h>
-#endif
-
 /* Local includes */
 #include "i40e.h"
 #include "i40e_diag.h"
@@ -10618,21 +10613,9 @@ static void i40e_print_features(struct i40e_pf *pf)
  **/
 static void i40e_get_platform_mac_addr(struct pci_dev *pdev, struct i40e_pf *pf)
 {
-	struct device_node *dp = pci_device_to_OF_node(pdev);
-	const unsigned char *addr;
-	u8 *mac_addr = pf->hw.mac.addr;
-
 	pf->flags &= ~I40E_FLAG_PF_MAC;
-	addr = of_get_mac_address(dp);
-	if (addr) {
-		ether_addr_copy(mac_addr, addr);
+	if (!eth_platform_get_mac_address(&pdev->dev, pf->hw.mac.addr))
 		pf->flags |= I40E_FLAG_PF_MAC;
-#ifdef CONFIG_SPARC
-	} else {
-		ether_addr_copy(mac_addr, idprom->id_ethaddr);
-		pf->flags |= I40E_FLAG_PF_MAC;
-#endif /* CONFIG_SPARC */
-	}
 }
 
 /**
-- 
2.5.0
