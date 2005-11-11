From: Adrian Bunk <bunk@stusta.de>
Subject: [2.6 patch] drivers/net/sk98lin/skge.c: make SkPciWriteCfgDWord() a static inline
Date: Fri, 11 Nov 2005 20:44:21 +0100
Message-ID: <20051111194421.GN5376@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751119AbVKKToZ@vger.kernel.org>
To: jgarzik@pobox.com
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

No external user and that small - such a function should be static 
inline and not a global function.


Signed-off-by: Adrian Bunk <bunk@stusta.de>

---

 drivers/net/sk98lin/h/skvpd.h |    8 ------
 drivers/net/sk98lin/skge.c    |   43 ++++++++++++++++------------------
 2 files changed, 21 insertions(+), 30 deletions(-)

--- linux-2.6.14-mm2-full/drivers/net/sk98lin/h/skvpd.h.old	2005-11-11 20:30:25.000000000 +0100
+++ linux-2.6.14-mm2-full/drivers/net/sk98lin/h/skvpd.h	2005-11-11 20:30:44.000000000 +0100
@@ -130,14 +130,12 @@
 #ifndef VPD_DO_IO
 #define VPD_OUT8(pAC,IoC,Addr,Val)	(void)SkPciWriteCfgByte(pAC,Addr,Val)
 #define VPD_OUT16(pAC,IoC,Addr,Val)	(void)SkPciWriteCfgWord(pAC,Addr,Val)
-#define VPD_OUT32(pAC,IoC,Addr,Val)	(void)SkPciWriteCfgDWord(pAC,Addr,Val)
 #define VPD_IN8(pAC,IoC,Addr,pVal)	(void)SkPciReadCfgByte(pAC,Addr,pVal)
 #define VPD_IN16(pAC,IoC,Addr,pVal)	(void)SkPciReadCfgWord(pAC,Addr,pVal)
 #define VPD_IN32(pAC,IoC,Addr,pVal)	(void)SkPciReadCfgDWord(pAC,Addr,pVal)
 #else	/* VPD_DO_IO */
 #define VPD_OUT8(pAC,IoC,Addr,Val)	SK_OUT8(IoC,PCI_C(Addr),Val)
 #define VPD_OUT16(pAC,IoC,Addr,Val)	SK_OUT16(IoC,PCI_C(Addr),Val)
-#define VPD_OUT32(pAC,IoC,Addr,Val)	SK_OUT32(IoC,PCI_C(Addr),Val)
 #define VPD_IN8(pAC,IoC,Addr,pVal)	SK_IN8(IoC,PCI_C(Addr),pVal)
 #define VPD_IN16(pAC,IoC,Addr,pVal)	SK_IN16(IoC,PCI_C(Addr),pVal)
 #define VPD_IN32(pAC,IoC,Addr,pVal)	SK_IN32(IoC,PCI_C(Addr),pVal)
@@ -155,12 +153,6 @@
 		else						\
 			SK_OUT16(pAC,PCI_C(Addr),Val);		\
 		}
-#define VPD_OUT32(pAC,Ioc,Addr,Val) {			\
-		if ((pAC)->DgT.DgUseCfgCycle)			\
-			SkPciWriteCfgDWord(pAC,Addr,Val);	\
-		else						\
-			SK_OUT32(pAC,PCI_C(Addr),Val); 		\
-		}
 #define VPD_IN8(pAC,Ioc,Addr,pVal) {			\
 		if ((pAC)->DgT.DgUseCfgCycle) 			\
 			SkPciReadCfgByte(pAC,Addr,pVal);	\
--- linux-2.6.14-mm2-full/drivers/net/sk98lin/skge.c.old	2005-11-11 20:31:05.000000000 +0100
+++ linux-2.6.14-mm2-full/drivers/net/sk98lin/skge.c	2005-11-11 20:32:39.000000000 +0100
@@ -279,6 +279,27 @@
 
 /*****************************************************************************
  *
+ *	SkPciWriteCfgDWord - write a 32 bit value to pci config space
+ *
+ * Description:
+ *	This routine writes a 32 bit value to the pci configuration
+ *	space.
+ *
+ * Returns:
+ *	0 - indicate everything worked ok.
+ *	!= 0 - error indication
+ */
+static inline int SkPciWriteCfgDWord(
+SK_AC *pAC,	/* Adapter Control structure pointer */
+int PciAddr,		/* PCI register address */
+SK_U32 Val)		/* pointer to store the read value */
+{
+	pci_write_config_dword(pAC->PciDev, PciAddr, Val);
+	return(0);
+} /* SkPciWriteCfgDWord */
+
+/*****************************************************************************
+ *
  * 	SkGeInitPCI - Init the PCI resources
  *
  * Description:
@@ -4085,28 +4106,6 @@
 
 /*****************************************************************************
  *
- *	SkPciWriteCfgDWord - write a 32 bit value to pci config space
- *
- * Description:
- *	This routine writes a 32 bit value to the pci configuration
- *	space.
- *
- * Returns:
- *	0 - indicate everything worked ok.
- *	!= 0 - error indication
- */
-int SkPciWriteCfgDWord(
-SK_AC *pAC,	/* Adapter Control structure pointer */
-int PciAddr,		/* PCI register address */
-SK_U32 Val)		/* pointer to store the read value */
-{
-	pci_write_config_dword(pAC->PciDev, PciAddr, Val);
-	return(0);
-} /* SkPciWriteCfgDWord */
-
-
-/*****************************************************************************
- *
  *	SkPciWriteCfgWord - write a 16 bit value to pci config space
  *
  * Description:
