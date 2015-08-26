From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 11/14] i40e: Remove redundant and unneeded messages
Date: Wed, 26 Aug 2015 15:49:30 -0700
Message-ID: <1440629373-21287-12-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1440629373-21287-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:12760 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757000AbbHZWti (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Aug 2015 18:49:38 -0400
In-Reply-To: <1440629373-21287-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>

The kernel notifies all VXLAN capable registered drivers, i.e. any
driver that implements ndo_add_vxlan_port(), of the addition of a
port so that the driver can track which ports are in use.  There's
no need to log this - it just fills the system log with useless and
irksome noise.

Also, when failing to init SR-IOV interfaces the driver was printing the
same message twice. Just remove the inner printk and let the outer message
catch enable as well as the other failures.

Change-ID: Id5ecb1d425c2a357ee2bc1635dab24553831dade
Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c        | 2 --
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 2 --
 2 files changed, 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index c0bfb55..5b60558 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -8068,8 +8068,6 @@ static void i40e_add_vxlan_port(struct net_device *netdev,
 	pf->vxlan_ports[next_idx] = port;
 	pf->pending_vxlan_bitmap |= BIT_ULL(next_idx);
 	pf->flags |= I40E_FLAG_VXLAN_FILTER_SYNC;
-
-	dev_info(&pf->pdev->dev, "adding vxlan port %d\n", ntohs(port));
 }
 
 /**
diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index 70a6fb1..ca7a568 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -921,8 +921,6 @@ int i40e_alloc_vfs(struct i40e_pf *pf, u16 num_alloc_vfs)
 	if (pci_num_vf(pf->pdev) != num_alloc_vfs) {
 		ret = pci_enable_sriov(pf->pdev, num_alloc_vfs);
 		if (ret) {
-			dev_err(&pf->pdev->dev,
-				"Failed to enable SR-IOV, error %d.\n", ret);
 			pf->num_alloc_vfs = 0;
 			goto err_iov;
 		}
-- 
2.4.3
