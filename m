From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 3/3] i40e: Fix possible memory leak in i40e_dbg_dump_desc
Date: Wed, 31 Dec 2014 16:04:15 -0800
Message-ID: <1420070655-28453-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1420070655-28453-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Joe Perches <joe@perches.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:8966 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751692AbbAAAET (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Dec 2014 19:04:19 -0500
In-Reply-To: <1420070655-28453-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>

I didn't notice that return in the code, fix it by
adding a goto out instead to free the memory.

Fixes:

> New smatch warnings:
> drivers/net/ethernet/intel/i40e/i40e_debugfs.c:832 i40e_dbg_dump_desc() warn: possible memory leak of 'ring'

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Joe Perches <joe@perches.com>
Tested-by: Jim Young <james.m.young@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_debugfs.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
index 433a558..cb0de45 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_debugfs.c
@@ -829,7 +829,7 @@ static void i40e_dbg_dump_desc(int cnt, int vsi_seid, int ring_id, int desc_n,
 		if (desc_n >= ring->count || desc_n < 0) {
 			dev_info(&pf->pdev->dev,
 				 "descriptor %d not found\n", desc_n);
-			return;
+			goto out;
 		}
 		if (!is_rx_ring) {
 			txd = I40E_TX_DESC(ring, desc_n);
@@ -855,6 +855,8 @@ static void i40e_dbg_dump_desc(int cnt, int vsi_seid, int ring_id, int desc_n,
 	} else {
 		dev_info(&pf->pdev->dev, "dump desc rx/tx <vsi_seid> <ring_id> [<desc_n>]\n");
 	}
+
+out:
 	kfree(ring);
 }
 
-- 
1.9.3
