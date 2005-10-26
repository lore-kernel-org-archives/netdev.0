From: Santiago Leon <santil@us.ibm.com>
Subject: [PATCH 5/5] ibmveth fix failed addbuf
Date: Wed, 26 Oct 2005 10:47:23 -0600
Message-ID: <20051026164609.21820.15714.sendpatchset@localhost.localdomain>
References: <20051026164532.21820.72673.sendpatchset@localhost.localdomain>
Cc: Santiago Leon <santil@us.ibm.com>, Jeff Garzik <jgarzik@pobox.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964827AbVJZQrm@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>, netdev <netdev@vger.kernel.org>,
	lkml <linux-kernel@vger.kernel.org>
In-Reply-To: <20051026164532.21820.72673.sendpatchset@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes a bug that happens when the hypervisor can't add a
buffer.  The old code wrote IBM_VETH_INVALID_MAP into the free_map
array, so next time the index was used, a ibmveth_assert() caught it and
called BUG().  The patch writes the right value into the free_map array
so that the index can be reused.

Signed-off-by: Santiago Leon <santil@us.ibm.com>
---

 drivers/net/ibmveth.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

--- a/drivers/net/ibmveth.c	2005-10-17 12:35:13.000000000 -0500
+++ b/drivers/net/ibmveth.c	2005-10-17 12:36:13.000000000 -0500
@@ -237,7 +237,7 @@
 		lpar_rc = h_add_logical_lan_buffer(adapter->vdev->unit_address, desc.desc);
 		    
 		if(lpar_rc != H_Success) {
-			pool->free_map[free_index] = IBM_VETH_INVALID_MAP;
+			pool->free_map[free_index] = index;
 			pool->skbuff[index] = NULL;
 			pool->consumer_index--;
 			dma_unmap_single(&adapter->vdev->dev,
