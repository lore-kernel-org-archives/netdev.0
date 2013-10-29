From: Gavin Shan <shangw@linux.vnet.ibm.com>
Subject: [PATCH v2 1/2] net/benet: Remove interface type
Date: Tue, 29 Oct 2013 17:30:56 +0800
Message-ID: <1383039057-28164-1-git-send-email-shangw@linux.vnet.ibm.com>
Cc: Sathya.Perla@emulex.com, davem@davemloft.net,
	Gavin Shan <shangw@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e7.ny.us.ibm.com ([32.97.182.137]:57525 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751795Ab3J2JbI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Oct 2013 05:31:08 -0400
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <shangw@linux.vnet.ibm.com>;
	Tue, 29 Oct 2013 05:31:07 -0400
Received: from b01cxnp23034.gho.pok.ibm.com (b01cxnp23034.gho.pok.ibm.com [9.57.198.29])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 90C5CC90045
	for <netdev@vger.kernel.org>; Tue, 29 Oct 2013 05:31:04 -0400 (EDT)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by b01cxnp23034.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r9T9V5k89371968
	for <netdev@vger.kernel.org>; Tue, 29 Oct 2013 09:31:05 GMT
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r9T9V4Bq018756
	for <netdev@vger.kernel.org>; Tue, 29 Oct 2013 05:31:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The interface type, which is being traced by "struct be_adapter::
if_type", isn't used currently. So we can remove that safely
according to Sathya's comments.

Signed-off-by: Gavin Shan <shangw@linux.vnet.ibm.com>
---
 drivers/net/ethernet/emulex/benet/be.h      |    1 -
 drivers/net/ethernet/emulex/benet/be_main.c |    5 -----
 2 files changed, 6 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index b2765eb..2c88ac2 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -470,7 +470,6 @@ struct be_adapter {
 	u32 rx_fc;		/* Rx flow control */
 	u32 tx_fc;		/* Tx flow control */
 	bool stats_cmd_sent;
-	u32 if_type;
 	struct {
 		u32 size;
 		u32 total_size;
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 03e0c74..8080a1a 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -4095,11 +4095,6 @@ static int be_roce_map_pci_bars(struct be_adapter *adapter)
 static int be_map_pci_bars(struct be_adapter *adapter)
 {
 	u8 __iomem *addr;
-	u32 sli_intf;
-
-	pci_read_config_dword(adapter->pdev, SLI_INTF_REG_OFFSET, &sli_intf);
-	adapter->if_type = (sli_intf & SLI_INTF_IF_TYPE_MASK) >>
-				SLI_INTF_IF_TYPE_SHIFT;
 
 	if (BEx_chip(adapter) && be_physfn(adapter)) {
 		adapter->csr = pci_iomap(adapter->pdev, 2, 0);
-- 
1.7.9.5
