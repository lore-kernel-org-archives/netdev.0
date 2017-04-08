From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 02/12] i40e: update error message when trying to add invalid filters
Date: Sat,  8 Apr 2017 02:55:43 -0700
Message-ID: <20170408095553.78307-3-jeffrey.t.kirsher@intel.com>
References: <20170408095553.78307-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:55938 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751532AbdDHJz6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 8 Apr 2017 05:55:58 -0400
In-Reply-To: <20170408095553.78307-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

Re-word the error message displayed when adding a filter with an
invalid flow type. Additionally, report a distinct error message when
the IPv4 protocol is at fault.

Change-ID: Iba3d85b87f8d383c97c8bdd180df34a6adf3ee67
Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index ebffca0cefac..d45f48c84ff7 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -533,14 +533,15 @@ int i40e_add_del_fdir(struct i40e_vsi *vsi,
 			break;
 		default:
 			/* We cannot support masking based on protocol */
-			goto unsupported_flow;
+			dev_info(&pf->pdev->dev, "Unsupported IPv4 protocol 0x%02x\n",
+				 input->ip4_proto);
+			return -EINVAL;
 		}
 		break;
 	default:
-unsupported_flow:
-		dev_info(&pf->pdev->dev, "Could not specify spec type %d\n",
+		dev_info(&pf->pdev->dev, "Unsupported flow type 0x%02x\n",
 			 input->flow_type);
-		ret = -EINVAL;
+		return -EINVAL;
 	}
 
 	/* The buffer allocated here will be normally be freed by
-- 
2.12.2
