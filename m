From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 2/6] i40e: use common failure flow
Date: Tue, 24 Sep 2013 02:45:06 -0700
Message-ID: <1380015910-25927-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1380015910-25927-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jesse Brandeburg <jesse.brandeburg@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Joe Perches <joe@perches.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:32601 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754040Ab3IXJpP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Sep 2013 05:45:15 -0400
In-Reply-To: <1380015910-25927-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

As mentioned by Joe Perches, we should be using
foo = alloc(...)
if (!foo)
	return -ENOMEM;

return 0;

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
CC: Joe Perches <joe@perches.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index 601d482..67f8fd5 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -101,10 +101,10 @@ int i40e_allocate_dma_mem_d(struct i40e_hw *hw, struct i40e_dma_mem *mem,
 	mem->size = ALIGN(size, alignment);
 	mem->va = dma_zalloc_coherent(&pf->pdev->dev, mem->size,
 				      &mem->pa, GFP_KERNEL);
-	if (mem->va)
-		return 0;
+	if (!mem->va)
+		return -ENOMEM;
 
-	return -ENOMEM;
+	return 0;
 }
 
 /**
@@ -136,10 +136,10 @@ int i40e_allocate_virt_mem_d(struct i40e_hw *hw, struct i40e_virt_mem *mem,
 	mem->size = size;
 	mem->va = kzalloc(size, GFP_KERNEL);
 
-	if (mem->va)
-		return 0;
+	if (!mem->va)
+		return -ENOMEM;
 
-	return -ENOMEM;
+	return 0;
 }
 
 /**
-- 
1.8.3.1
