From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/15] i40e: warn at the right time
Date: Fri,  3 Apr 2015 05:04:50 -0700
Message-ID: <1428062698-16180-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1428062698-16180-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Mitch Williams <mitch.a.williams@intel.com>,
	netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
	jogreene@redhat.com, Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:40006 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751005AbbDCMFf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Apr 2015 08:05:35 -0400
In-Reply-To: <1428062698-16180-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mitch Williams <mitch.a.williams@intel.com>

The call to pci_disable_sriov got moved, but the message about not
disabling VFs didn't move. So move it. While we're at, reword the
message a bit to make it more consistent with other driver messages.

Change-ID: I17d3e15e4fcfd5c9431a96ecb0117d728d3da18b
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
index bb18412..184b003 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c
@@ -734,6 +734,8 @@ void i40e_free_vfs(struct i40e_pf *pf)
 	 */
 	if (!pci_vfs_assigned(pf->pdev))
 		pci_disable_sriov(pf->pdev);
+	else
+		dev_warn(&pf->pdev->dev, "VFs are assigned - not disabling SR-IOV\n");
 
 	msleep(20); /* let any messages in transit get finished up */
 
@@ -763,9 +765,6 @@ void i40e_free_vfs(struct i40e_pf *pf)
 			bit_idx = (hw->func_caps.vf_base_id + vf_id) % 32;
 			wr32(hw, I40E_GLGEN_VFLRSTAT(reg_idx), (1 << bit_idx));
 		}
-	} else {
-		dev_warn(&pf->pdev->dev,
-			 "unable to disable SR-IOV because VFs are assigned.\n");
 	}
 	clear_bit(__I40E_VF_DISABLE, &pf->state);
 }
-- 
1.9.3
