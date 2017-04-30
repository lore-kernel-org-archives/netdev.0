From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 06/13] i40e: remove unnecessary msleep() delay in i40e_free_vfs
Date: Sun, 30 Apr 2017 06:24:44 -0700
Message-ID: <20170430132451.68494-7-jeffrey.t.kirsher@intel.com>
References: <20170430132451.68494-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:15380 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1163957AbdD3NZQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 30 Apr 2017 09:25:16 -0400
In-Reply-To: <20170430132451.68494-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

The delay was added because of a desire to ensure that the VF driver can
finish up removing. However, pci_disable_sriov already has its own
ssleep() call that will sleep for an entire second, so there is no
reason to add extra delay on top of this by using msleep here. In
practice, an msleep() won't have a huge impact on timing but there is no
real value in keeping it, so lets just simplify the code and remove it.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 2 +-
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 2 --
 drivers/net/ethernet/intel/i40evf/i40evf_main.c    | 2 +-
 3 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index f44affc7e08c..20850a646e6c 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -47,7 +47,7 @@ static const char i40e_driver_string[] =
 
 #define DRV_VERSION_MAJOR 2
 #define DRV_VERSION_MINOR 1
-#define DRV_VERSION_BUILD 7
+#define DRV_VERSION_BUILD 14
 #define DRV_VERSION __stringify(DRV_VERSION_MAJOR) "." \
 	     __stringify(DRV_VERSION_MINOR) "." \
 	     __stringify(DRV_VERSION_BUILD)    DRV_KERN
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 2a47a6474366..29f53f032c3c 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -1219,8 +1219,6 @@ void i40e_free_vfs(struct i40e_pf *pf)
 	else
 		dev_warn(&pf->pdev->dev, "VFs are assigned - not disabling SR-IOV\n");
 
-	msleep(20); /* let any messages in transit get finished up */
-
 	/* free up VF resources */
 	tmp = pf->num_alloc_vfs;
 	pf->num_alloc_vfs = 0;
diff --git a/drivers/net/ethernet/intel/i40evf/i40evf_main.c b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
index 5915273c372f..3ea81bd0db32 100644
--- a/drivers/net/ethernet/intel/i40evf/i40evf_main.c
+++ b/drivers/net/ethernet/intel/i40evf/i40evf_main.c
@@ -46,7 +46,7 @@ static const char i40evf_driver_string[] =
 
 #define DRV_VERSION_MAJOR 2
 #define DRV_VERSION_MINOR 1
-#define DRV_VERSION_BUILD 7
+#define DRV_VERSION_BUILD 14
 #define DRV_VERSION __stringify(DRV_VERSION_MAJOR) "." \
 	     __stringify(DRV_VERSION_MINOR) "." \
 	     __stringify(DRV_VERSION_BUILD) \
-- 
2.12.2
