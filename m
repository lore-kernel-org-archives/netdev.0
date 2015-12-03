From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 01/15] i40evf: increase max number of queues
Date: Thu,  3 Dec 2015 05:25:46 -0800
Message-ID: <1449149160-105219-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1449149160-105219-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:6976 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750849AbbLCN0D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Dec 2015 08:26:03 -0500
In-Reply-To: <1449149160-105219-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

Future devices will allow for more queue pairs, so allocate a netdev
that can handle them. While we're at it, get rid of the separate
MAX_TX/MAX_RX defines. Since we always get matched queue pairs, having
these makes no sense.

Change-ID: I0e3556cd9a962506e509eb7c0afa36b329e8cb51
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40evf/i40evf.h      | 3 +--
 drivers/net/ethernet/intel/i40evf/i40evf_main.c | 3 +--
 2 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40evf/i40evf.h b/drivers/net/ethernet/intel/i40evf/i40evf.h
index a6318c4..be1b72b 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf.h
+++ b/drivers/net/ethernet/intel/i40evf/i40evf.h
@@ -97,8 +97,7 @@ struct i40e_vsi {
 #define I40E_TX_DESC(R, i) (&(((struct i40e_tx_desc *)((R)->desc))[i]))
 #define I40E_TX_CTXTDESC(R, i) \
 	(&(((struct i40e_tx_context_desc *)((R)->desc))[i]))
-#define MAX_RX_QUEUES 8
-#define MAX_TX_QUEUES MAX_RX_QUEUES
+#define MAX_QUEUES 16
 
 #define I40EVF_HKEY_ARRAY_SIZE ((I40E_VFQF_HKEY_MAX_INDEX + 1) * 4)
 #define I40EVF_HLUT_ARRAY_SIZE ((I40E_VFQF_HLUT_MAX_INDEX + 1) * 4)
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 7ef1042..38f882c 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -2615,8 +2615,7 @@ static int i40evf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	pci_set_master(pdev);
 
-	netdev = alloc_etherdev_mq(sizeof(struct i40evf_adapter),
-				   MAX_TX_QUEUES);
+	netdev = alloc_etherdev_mq(sizeof(struct i40evf_adapter), MAX_QUEUES);
 	if (!netdev) {
 		err = -ENOMEM;
 		goto err_alloc_etherdev;
-- 
2.5.0
