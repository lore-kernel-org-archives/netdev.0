From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH 1/2] net: ethernet: ucc_geth: fix MEM_PART_MURAM mode
Date: Tue,  7 Feb 2017 10:05:09 +0100 (CET)
Message-ID: <d25ee7a13b60dcd005c59169feacb18fb69a06c1.1486456900.git.christophe.leroy@c-s.fr>
References: <cover.1486456900.git.christophe.leroy@c-s.fr>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
        netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: Li Yang <leoli@freescale.com>, Qiang Zhao <qiang.zhao@nxp.com>,
        Scott Wood <oss@buserror.net>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1486456900.git.christophe.leroy@c-s.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since commit 5093bb965a163 ("powerpc/QE: switch to the cpm_muram
implementation"), muram area is not part of immrbar mapping anymore
so immrbar_virt_to_phys() is not usable anymore.

Fixes: 5093bb965a163 ("powerpc/QE: switch to the cpm_muram implementation)
Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
---
 drivers/net/ethernet/freescale/ucc_geth.c | 8 +++-----
 include/soc/fsl/qe/qe.h                   | 1 +
 2 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/freescale/ucc_geth.c b/drivers/net/ethernet/freescale/ucc_geth.c
index 3f7ae9f..f77ba9f 100644
--- a/drivers/net/ethernet/freescale/ucc_geth.c
+++ b/drivers/net/ethernet/freescale/ucc_geth.c
@@ -2594,11 +2594,10 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 		} else if (ugeth->ug_info->uf_info.bd_mem_part ==
 			   MEM_PART_MURAM) {
 			out_be32(&ugeth->p_send_q_mem_reg->sqqd[i].bd_ring_base,
-				 (u32) immrbar_virt_to_phys(ugeth->
-							    p_tx_bd_ring[i]));
+				 (u32)qe_muram_dma(ugeth->p_tx_bd_ring[i]));
 			out_be32(&ugeth->p_send_q_mem_reg->sqqd[i].
 				 last_bd_completed_address,
-				 (u32) immrbar_virt_to_phys(endOfRing));
+				 (u32)qe_muram_dma(endOfRing));
 		}
 	}
 
@@ -2844,8 +2843,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 		} else if (ugeth->ug_info->uf_info.bd_mem_part ==
 			   MEM_PART_MURAM) {
 			out_be32(&ugeth->p_rx_bd_qs_tbl[i].externalbdbaseptr,
-				 (u32) immrbar_virt_to_phys(ugeth->
-							    p_rx_bd_ring[i]));
+				 (u32)qe_muram_dma(ugeth->p_rx_bd_ring[i]));
 		}
 		/* rest of fields handled by QE */
 	}
diff --git a/include/soc/fsl/qe/qe.h b/include/soc/fsl/qe/qe.h
index 70339d7..0cd4c1147 100644
--- a/include/soc/fsl/qe/qe.h
+++ b/include/soc/fsl/qe/qe.h
@@ -243,6 +243,7 @@ static inline int qe_alive_during_sleep(void)
 #define qe_muram_free cpm_muram_free
 #define qe_muram_addr cpm_muram_addr
 #define qe_muram_offset cpm_muram_offset
+#define qe_muram_dma cpm_muram_dma
 
 #define qe_setbits32(_addr, _v) iowrite32be(ioread32be(_addr) |  (_v), (_addr))
 #define qe_clrbits32(_addr, _v) iowrite32be(ioread32be(_addr) & ~(_v), (_addr))
-- 
2.10.1
