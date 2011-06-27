From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next-2.6 2/3] be2net: get rid of multi_rxq module param
Date: Mon, 27 Jun 2011 12:11:25 +0530
Message-ID: <737fdf75-9b60-476b-b5a5-bf8adac5501a@exht1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sathya Perla <sathya.perla@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:48989 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756718Ab1F0GlO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2011 02:41:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/benet/be_main.c |    6 +-----
 1 files changed, 1 insertions(+), 5 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 5ca06b0..2373d39 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -33,10 +33,6 @@ module_param(num_vfs, uint, S_IRUGO);
 MODULE_PARM_DESC(rx_frag_size, "Size of a fragment that holds rcvd data.");
 MODULE_PARM_DESC(num_vfs, "Number of PCI VFs to initialize");
 
-static bool multi_rxq = true;
-module_param(multi_rxq, bool, S_IRUGO | S_IWUSR);
-MODULE_PARM_DESC(multi_rxq, "Multi Rx Queue support. Enabled by default");
-
 static DEFINE_PCI_DEVICE_TABLE(be_dev_ids) = {
 	{ PCI_DEVICE(BE_VENDOR_ID, BE_DEVICE_ID1) },
 	{ PCI_DEVICE(BE_VENDOR_ID, BE_DEVICE_ID2) },
@@ -1785,7 +1781,7 @@ static void be_rx_queues_destroy(struct be_adapter *adapter)
 
 static u32 be_num_rxqs_want(struct be_adapter *adapter)
 {
-	if (multi_rxq && (adapter->function_caps & BE_FUNCTION_CAPS_RSS) &&
+	if ((adapter->function_caps & BE_FUNCTION_CAPS_RSS) &&
 		!adapter->sriov_enabled && !(adapter->function_mode & 0x400)) {
 		return 1 + MAX_RSS_QS; /* one default non-RSS queue */
 	} else {
-- 
1.7.4

