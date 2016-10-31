From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 20/22] i40e: Fix for division by zero
Date: Mon, 31 Oct 2016 15:29:50 -0700
Message-ID: <1477952992-125662-21-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1477952992-125662-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Michal Kosiarz <michal.kosiarz@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:4577 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S947636AbcJaWaE (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 31 Oct 2016 18:30:04 -0400
In-Reply-To: <1477952992-125662-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Kosiarz <michal.kosiarz@intel.com>

For some cases when reading from device are incorrect or image is
incorrect, this part of code causes crash due to division by zero.

Change-ID: I8961029a7a87b0a479995823ef8fcbf6471405e1
Signed-off-by: Michal Kosiarz <michal.kosiarz@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_common.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_common.c b/drivers/net/ethernet/intel/i40e/i40e_common.c
index a475946..98791ba 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_common.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_common.c
@@ -3313,8 +3313,10 @@ static void i40e_parse_discover_capabilities(struct i40e_hw *hw, void *buff,
 	/* partition id is 1-based, and functions are evenly spread
 	 * across the ports as partitions
 	 */
-	hw->partition_id = (hw->pf_id / hw->num_ports) + 1;
-	hw->num_partitions = num_functions / hw->num_ports;
+	if (hw->num_ports != 0) {
+		hw->partition_id = (hw->pf_id / hw->num_ports) + 1;
+		hw->num_partitions = num_functions / hw->num_ports;
+	}
 
 	/* additional HW specific goodies that might
 	 * someday be HW version specific
-- 
2.7.4
