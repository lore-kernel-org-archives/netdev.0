From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 09/14] i40e: remove unnecessary __packed
Date: Fri,  3 Feb 2017 18:56:40 -0800
Message-ID: <20170204025645.174793-10-jeffrey.t.kirsher@intel.com>
References: <20170204025645.174793-1-jeffrey.t.kirsher@intel.com>
Cc: Tushar Dave <tushar.n.dave@oracle.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:64701 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753523AbdBDC4u (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 3 Feb 2017 21:56:50 -0500
In-Reply-To: <20170204025645.174793-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tushar Dave <tushar.n.dave@oracle.com>

'struct i40e_dma_mem' defined with 'packed' directive causing kernel
unaligned errors on sparc.

e.g.
i40e: Intel(R) Ethernet Connection XL710 Network Driver - version
1.6.16-k
i40e: Copyright (c) 2013 - 2014 Intel Corporation.
Kernel unaligned access at TPC[44894c] dma_4v_alloc_coherent+0x1ac/0x300
Kernel unaligned access at TPC[44894c] dma_4v_alloc_coherent+0x1ac/0x300
Kernel unaligned access at TPC[44894c] dma_4v_alloc_coherent+0x1ac/0x300
Kernel unaligned access at TPC[44894c] dma_4v_alloc_coherent+0x1ac/0x300
Kernel unaligned access at TPC[44894c] dma_4v_alloc_coherent+0x1ac/0x300
i40e 0000:03:00.0: fw 5.1.40981 api 1.5 nvm 5.04 0x80002548 0.0.0

This can be fixed with get_unaligned/put_unaligned(). However no
reference in driver shows that 'struct i40e_dma_mem' directly shoved
into NIC hardware. But instead fields of the struct are being read and
used for hardware. Therefore, __packed is unnecessary for 'struct
i40e_dma_mem'.

In addition, although 'struct i40e_virt_mem' doesn't cause any
unaligned access, keeping it packed is unnecessary as well because
of aforementioned reason.

This change make 'struct i40e_dma_mem' and 'struct i40e_virt_mem'
unpacked.

Signed-off-by: Tushar Dave <tushar.n.dave@oracle.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_osdep.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_osdep.h b/drivers/net/ethernet/intel/i40e/i40e_osdep.h
index 5b6feb7..be74bcf 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_osdep.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_osdep.h
@@ -55,7 +55,7 @@ struct i40e_dma_mem {
 	void *va;
 	dma_addr_t pa;
 	u32 size;
-} __packed;
+};
 
 #define i40e_allocate_dma_mem(h, m, unused, s, a) \
 			i40e_allocate_dma_mem_d(h, m, s, a)
@@ -64,7 +64,7 @@ struct i40e_dma_mem {
 struct i40e_virt_mem {
 	void *va;
 	u32 size;
-} __packed;
+};
 
 #define i40e_allocate_virt_mem(h, m, s) i40e_allocate_virt_mem_d(h, m, s)
 #define i40e_free_virt_mem(h, m) i40e_free_virt_mem_d(h, m)
-- 
2.10.2
