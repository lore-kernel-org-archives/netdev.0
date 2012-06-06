From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 3/7] be2net: do not modify PCI MaxReadReq size
Date: Wed, 6 Jun 2012 11:07:19 +0530
Message-ID: <75090e47-b04c-45d1-bf89-2b068b32b02d@exht1.ad.emulex.com>
References: <1338961043-26820-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sathya Perla <sathya.perla@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:2015 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753280Ab2FFFwa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jun 2012 01:52:30 -0400
In-Reply-To: <1338961043-26820-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Setting the PCI MRRS to a value of 4096 (overriding the system decided
value) had provided perf improvement in TX.
But, IBM has provided feedback that on POWER platforms, this value is set
by the system firmware, and drivers modifying this value can cause
unpredictable results (like EEH errors.) So, backing off this change.
On POWER7 platforms most slots, it seems, do get a MRRS of 4096.

This patch reverts the following commit:
"be2net: Modified PCI MaxReadReq size to 4096 bytes"
commit 5a56eb10babbcd7b3796dc3c28c271260aa3608d.

Suggested-by: Brian King <bjking1@us.ibm.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index cfbec8b..695c3cf 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -2766,8 +2766,6 @@ static int be_setup(struct be_adapter *adapter)
 		be_cmd_set_flow_control(adapter, adapter->tx_fc,
 					adapter->rx_fc);
 
-	pcie_set_readrq(adapter->pdev, 4096);
-
 	if (be_physfn(adapter) && num_vfs) {
 		if (adapter->dev_num_vfs)
 			be_vf_setup(adapter);
-- 
1.7.4
