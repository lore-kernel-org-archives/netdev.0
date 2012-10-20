From: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
Subject: [PATCH net-next 11/14] be2net: Enabling Wake-on-LAN is not supported in S5 state
Date: Sat, 20 Oct 2012 21:34:00 +0530
Message-ID: <c619f5e1-0bb4-4a88-929c-fd19707c907a@CMEXHTCAS1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>,
	Vasundhara Volam <vasundhara.volam@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:22361 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754883Ab2JTQFK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Oct 2012 12:05:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

be_shutdown is enabling wake-on-lan by calling be_setup_wol.
Emulex adapter do not support wake-on-lan in S5 state.

Signed-off-by: Vasundhara Volam <vasundhara.volam@emulex.com>
Signed-off-by: Padmanabh Ratnakar <padmanabh.ratnakar@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 136ed64..ab077fb 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -4165,9 +4165,6 @@ static void be_shutdown(struct pci_dev *pdev)
 
 	netif_device_detach(adapter->netdev);
 
-	if (adapter->wol)
-		be_setup_wol(adapter, true);
-
 	be_cmd_reset_function(adapter);
 
 	pci_disable_device(pdev);
-- 
1.6.0.2
