From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: [PATCH 2/2] soc/fsl/qe: get rid of immrbar_virt_to_phys()
Date: Tue,  7 Feb 2017 10:05:11 +0100 (CET)
Message-ID: <804a373374f8ea17d971c4b087fcbe24c0edced7.1486456900.git.christophe.leroy@c-s.fr>
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

immrbar_virt_to_phys() is not used anymore

Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
---
 drivers/soc/fsl/qe/qe.c       |  4 +---
 include/soc/fsl/qe/immap_qe.h | 19 -------------------
 2 files changed, 1 insertion(+), 22 deletions(-)

diff --git a/drivers/soc/fsl/qe/qe.c b/drivers/soc/fsl/qe/qe.c
index ade168f..d9c04f5 100644
--- a/drivers/soc/fsl/qe/qe.c
+++ b/drivers/soc/fsl/qe/qe.c
@@ -66,7 +66,7 @@ static unsigned int qe_num_of_snum;
 
 static phys_addr_t qebase = -1;
 
-phys_addr_t get_qe_base(void)
+static phys_addr_t get_qe_base(void)
 {
 	struct device_node *qe;
 	int ret;
@@ -90,8 +90,6 @@ phys_addr_t get_qe_base(void)
 	return qebase;
 }
 
-EXPORT_SYMBOL(get_qe_base);
-
 void qe_reset(void)
 {
 	if (qe_immr == NULL)
diff --git a/include/soc/fsl/qe/immap_qe.h b/include/soc/fsl/qe/immap_qe.h
index c76ef30..7baaabd 100644
--- a/include/soc/fsl/qe/immap_qe.h
+++ b/include/soc/fsl/qe/immap_qe.h
@@ -464,25 +464,6 @@ struct qe_immap {
 } __attribute__ ((packed));
 
 extern struct qe_immap __iomem *qe_immr;
-extern phys_addr_t get_qe_base(void);
-
-/*
- * Returns the offset within the QE address space of the given pointer.
- *
- * Note that the QE does not support 36-bit physical addresses, so if
- * get_qe_base() returns a number above 4GB, the caller will probably fail.
- */
-static inline phys_addr_t immrbar_virt_to_phys(void *address)
-{
-	void *q = (void *)qe_immr;
-
-	/* Is it a MURAM address? */
-	if ((address >= q) && (address < (q + QE_IMMAP_SIZE)))
-		return get_qe_base() + (address - q);
-
-	/* It's an address returned by kmalloc */
-	return virt_to_phys(address);
-}
 
 #endif /* __KERNEL__ */
 #endif /* _ASM_POWERPC_IMMAP_QE_H */
-- 
2.10.1
