From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [PATCH net 4/7] be2net: Fix number of VLANs supported in UMC mode
 for BE3-R.
Date: Fri, 27 Sep 2013 15:18:16 -0500
Message-ID: <20130927201816.GA4565@emulex.com>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:14700 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752508Ab3I0UST (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Sep 2013 16:18:19 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In BE3-R, when UMC is enabled, the number of VLANs that can be added
to the interface is reduced to 15.

Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be.h      | 1 +
 drivers/net/ethernet/emulex/benet/be_main.c | 2 ++
 2 files changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/emulex/benet/be.h b/drivers/net/ethernet/emulex/benet/be.h
index 95d303d..db02023 100644
--- a/drivers/net/ethernet/emulex/benet/be.h
+++ b/drivers/net/ethernet/emulex/benet/be.h
@@ -88,6 +88,7 @@ static inline char *nic_name(struct pci_dev *pdev)
 #define BE_MIN_MTU		256
 
 #define BE_NUM_VLANS_SUPPORTED	64
+#define BE_UMC_NUM_VLANS_SUPPORTED	15
 #define BE_MAX_EQD		96u
 #define	BE_MAX_TX_FRAG_COUNT	30
 
diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 036f583..2962d2f 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -2985,6 +2985,8 @@ static void BEx_get_resources(struct be_adapter *adapter,
 
 	if (adapter->function_mode & FLEX10_MODE)
 		res->max_vlans = BE_NUM_VLANS_SUPPORTED/8;
+	else if (adapter->function_mode & UMC_ENABLED)
+		res->max_vlans = BE_UMC_NUM_VLANS_SUPPORTED;
 	else
 		res->max_vlans = BE_NUM_VLANS_SUPPORTED;
 	res->max_mcast_mac = BE_MAX_MC;
-- 
1.8.1.2
