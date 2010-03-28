From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next trivial] drivers/net/ipg: Remove invalid
 IPG_DDEBUG_MSG uses, neaten
Date: Sun, 28 Mar 2010 11:35:45 -0700
Message-ID: <1269801345.1500.32.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>,
	Sorbica Shieh <sorbica@icplus.com.tw>,
	Jesse Huang <jesse@icplus.com.tw>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1167 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754858Ab0C1Sfq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Mar 2010 14:35:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some no longer valid IPG_DDEBUG_MSG uses are removed
Validate IPG_DDEBUG_MSG arguments when not #defined
Neaten #defines
marco/macro typo correction

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ipg.c |    5 --
 drivers/net/ipg.h |  109 +++++++++++++++++++++++++++++-----------------------
 2 files changed, 61 insertions(+), 53 deletions(-)

diff --git a/drivers/net/ipg.c b/drivers/net/ipg.c
index 150415e..0d7ad3f 100644
--- a/drivers/net/ipg.c
+++ b/drivers/net/ipg.c
@@ -1547,8 +1547,6 @@ static void ipg_reset_after_host_error(struct work_struct *work)
 		container_of(work, struct ipg_nic_private, task.work);
 	struct net_device *dev = sp->dev;
 
-	IPG_DDEBUG_MSG("DMACtrl = %8.8x\n", ioread32(sp->ioaddr + IPG_DMACTRL));
-
 	/*
 	 * Acknowledge HostError interrupt by resetting
 	 * IPG DMA and HOST.
@@ -1825,9 +1823,6 @@ static int ipg_nic_stop(struct net_device *dev)
 
 	netif_stop_queue(dev);
 
-	IPG_DDEBUG_MSG("RFDlistendCount = %i\n", sp->RFDlistendCount);
-	IPG_DDEBUG_MSG("RFDListCheckedCount = %i\n", sp->rxdCheckedCount);
-	IPG_DDEBUG_MSG("EmptyRFDListCount = %i\n", sp->EmptyRFDListCount);
 	IPG_DUMPTFDLIST(dev);
 
 	do {
diff --git a/drivers/net/ipg.h b/drivers/net/ipg.h
index dfc2541..6ce0273 100644
--- a/drivers/net/ipg.h
+++ b/drivers/net/ipg.h
@@ -29,7 +29,7 @@
 /* GMII based PHY IDs */
 #define		NS				0x2000
 #define		MARVELL				0x0141
-#define		ICPLUS_PHY		0x243
+#define		ICPLUS_PHY			0x243
 
 /* NIC Physical Layer Device MII register fields. */
 #define         MII_PHY_SELECTOR_IEEE8023       0x0001
@@ -96,31 +96,31 @@ enum ipg_regs {
 };
 
 /* Ethernet MIB statistic register offsets. */
-#define	IPG_OCTETRCVOK		0xA8
+#define	IPG_OCTETRCVOK			0xA8
 #define	IPG_MCSTOCTETRCVDOK		0xAC
 #define	IPG_BCSTOCTETRCVOK		0xB0
 #define	IPG_FRAMESRCVDOK		0xB4
 #define	IPG_MCSTFRAMESRCVDOK		0xB8
 #define	IPG_BCSTFRAMESRCVDOK		0xBE
 #define	IPG_MACCONTROLFRAMESRCVD	0xC6
-#define	IPG_FRAMETOOLONGERRRORS	0xC8
-#define	IPG_INRANGELENGTHERRORS	0xCA
-#define	IPG_FRAMECHECKSEQERRORS	0xCC
-#define	IPG_FRAMESLOSTRXERRORS	0xCE
-#define	IPG_OCTETXMTOK		0xD0
+#define	IPG_FRAMETOOLONGERRRORS		0xC8
+#define	IPG_INRANGELENGTHERRORS		0xCA
+#define	IPG_FRAMECHECKSEQERRORS		0xCC
+#define	IPG_FRAMESLOSTRXERRORS		0xCE
+#define	IPG_OCTETXMTOK			0xD0
 #define	IPG_MCSTOCTETXMTOK		0xD4
 #define	IPG_BCSTOCTETXMTOK		0xD8
 #define	IPG_FRAMESXMTDOK		0xDC
 #define	IPG_MCSTFRAMESXMTDOK		0xE0
-#define	IPG_FRAMESWDEFERREDXMT	0xE4
+#define	IPG_FRAMESWDEFERREDXMT		0xE4
 #define	IPG_LATECOLLISIONS		0xE8
 #define	IPG_MULTICOLFRAMES		0xEC
 #define	IPG_SINGLECOLFRAMES		0xF0
 #define	IPG_BCSTFRAMESXMTDOK		0xF6
-#define	IPG_CARRIERSENSEERRORS	0xF8
+#define	IPG_CARRIERSENSEERRORS		0xF8
 #define	IPG_MACCONTROLFRAMESXMTDOK	0xFA
-#define	IPG_FRAMESABORTXSCOLLS	0xFC
-#define	IPG_FRAMESWEXDEFERRAL	0xFE
+#define	IPG_FRAMESABORTXSCOLLS		0xFC
+#define	IPG_FRAMESWEXDEFERRAL		0xFE
 
 /* RMON statistic register offsets. */
 #define	IPG_ETHERSTATSCOLLISIONS			0x100
@@ -134,8 +134,8 @@ enum ipg_regs {
 #define	IPG_ETHERSTATSPKTS1024TO1518OCTESTSTRANSMIT	0x120
 #define	IPG_ETHERSTATSCRCALIGNERRORS			0x124
 #define	IPG_ETHERSTATSUNDERSIZEPKTS			0x128
-#define	IPG_ETHERSTATSFRAGMENTS			0x12C
-#define	IPG_ETHERSTATSJABBERS			0x130
+#define	IPG_ETHERSTATSFRAGMENTS				0x12C
+#define	IPG_ETHERSTATSJABBERS				0x130
 #define	IPG_ETHERSTATSOCTETS				0x134
 #define	IPG_ETHERSTATSPKTS				0x138
 #define	IPG_ETHERSTATSPKTS64OCTESTS			0x13C
@@ -154,10 +154,10 @@ enum ipg_regs {
 #define	IPG_ETHERSTATSDROPEVENTS			0xCE
 
 /* Serial EEPROM offsets */
-#define	IPG_EEPROM_CONFIGPARAM	0x00
+#define	IPG_EEPROM_CONFIGPARAM		0x00
 #define	IPG_EEPROM_ASICCTRL		0x01
 #define	IPG_EEPROM_SUBSYSTEMVENDORID	0x02
-#define	IPG_EEPROM_SUBSYSTEMID	0x03
+#define	IPG_EEPROM_SUBSYSTEMID		0x03
 #define	IPG_EEPROM_STATIONADDRESS0	0x10
 #define	IPG_EEPROM_STATIONADDRESS1	0x11
 #define	IPG_EEPROM_STATIONADDRESS2	0x12
@@ -168,16 +168,16 @@ enum ipg_regs {
 
 /* IOBaseAddress */
 #define         IPG_PIB_RSVD_MASK		0xFFFFFE01
-#define         IPG_PIB_IOBASEADDRESS	0xFFFFFF00
-#define         IPG_PIB_IOBASEADDRIND	0x00000001
+#define         IPG_PIB_IOBASEADDRESS		0xFFFFFF00
+#define         IPG_PIB_IOBASEADDRIND		0x00000001
 
 /* MemBaseAddress */
 #define         IPG_PMB_RSVD_MASK		0xFFFFFE07
-#define         IPG_PMB_MEMBASEADDRIND	0x00000001
+#define         IPG_PMB_MEMBASEADDRIND		0x00000001
 #define         IPG_PMB_MEMMAPTYPE		0x00000006
 #define         IPG_PMB_MEMMAPTYPE0		0x00000002
 #define         IPG_PMB_MEMMAPTYPE1		0x00000004
-#define         IPG_PMB_MEMBASEADDRESS	0xFFFFFE00
+#define         IPG_PMB_MEMBASEADDRESS		0xFFFFFE00
 
 /* ConfigStatus */
 #define IPG_CS_RSVD_MASK                0xFFB0
@@ -196,20 +196,20 @@ enum ipg_regs {
 
 /* TFDList, TFC */
 #define	IPG_TFC_RSVD_MASK			0x0000FFFF9FFFFFFF
-#define	IPG_TFC_FRAMEID			0x000000000000FFFF
+#define	IPG_TFC_FRAMEID				0x000000000000FFFF
 #define	IPG_TFC_WORDALIGN			0x0000000000030000
 #define	IPG_TFC_WORDALIGNTODWORD		0x0000000000000000
-#define	IPG_TFC_WORDALIGNTOWORD		0x0000000000020000
+#define	IPG_TFC_WORDALIGNTOWORD			0x0000000000020000
 #define	IPG_TFC_WORDALIGNDISABLED		0x0000000000030000
 #define	IPG_TFC_TCPCHECKSUMENABLE		0x0000000000040000
 #define	IPG_TFC_UDPCHECKSUMENABLE		0x0000000000080000
 #define	IPG_TFC_IPCHECKSUMENABLE		0x0000000000100000
 #define	IPG_TFC_FCSAPPENDDISABLE		0x0000000000200000
 #define	IPG_TFC_TXINDICATE			0x0000000000400000
-#define	IPG_TFC_TXDMAINDICATE		0x0000000000800000
+#define	IPG_TFC_TXDMAINDICATE			0x0000000000800000
 #define	IPG_TFC_FRAGCOUNT			0x000000000F000000
-#define	IPG_TFC_VLANTAGINSERT		0x0000000010000000
-#define	IPG_TFC_TFDDONE			0x0000000080000000
+#define	IPG_TFC_VLANTAGINSERT			0x0000000010000000
+#define	IPG_TFC_TFDDONE				0x0000000080000000
 #define	IPG_TFC_VID				0x00000FFF00000000
 #define	IPG_TFC_CFI				0x0000100000000000
 #define	IPG_TFC_USERPRIORITY			0x0000E00000000000
@@ -217,35 +217,35 @@ enum ipg_regs {
 /* TFDList, FragInfo */
 #define	IPG_TFI_RSVD_MASK			0xFFFF00FFFFFFFFFF
 #define	IPG_TFI_FRAGADDR			0x000000FFFFFFFFFF
-#define	IPG_TFI_FRAGLEN			0xFFFF000000000000LL
+#define	IPG_TFI_FRAGLEN				0xFFFF000000000000LL
 
 /* RFD data structure masks. */
 
 /* RFDList, RFS */
 #define	IPG_RFS_RSVD_MASK			0x0000FFFFFFFFFFFF
 #define	IPG_RFS_RXFRAMELEN			0x000000000000FFFF
-#define	IPG_RFS_RXFIFOOVERRUN		0x0000000000010000
+#define	IPG_RFS_RXFIFOOVERRUN			0x0000000000010000
 #define	IPG_RFS_RXRUNTFRAME			0x0000000000020000
 #define	IPG_RFS_RXALIGNMENTERROR		0x0000000000040000
 #define	IPG_RFS_RXFCSERROR			0x0000000000080000
 #define	IPG_RFS_RXOVERSIZEDFRAME		0x0000000000100000
-#define	IPG_RFS_RXLENGTHERROR		0x0000000000200000
+#define	IPG_RFS_RXLENGTHERROR			0x0000000000200000
 #define	IPG_RFS_VLANDETECTED			0x0000000000400000
 #define	IPG_RFS_TCPDETECTED			0x0000000000800000
 #define	IPG_RFS_TCPERROR			0x0000000001000000
 #define	IPG_RFS_UDPDETECTED			0x0000000002000000
 #define	IPG_RFS_UDPERROR			0x0000000004000000
 #define	IPG_RFS_IPDETECTED			0x0000000008000000
-#define	IPG_RFS_IPERROR			0x0000000010000000
+#define	IPG_RFS_IPERROR				0x0000000010000000
 #define	IPG_RFS_FRAMESTART			0x0000000020000000
 #define	IPG_RFS_FRAMEEND			0x0000000040000000
-#define	IPG_RFS_RFDDONE			0x0000000080000000
+#define	IPG_RFS_RFDDONE				0x0000000080000000
 #define	IPG_RFS_TCI				0x0000FFFF00000000
 
 /* RFDList, FragInfo */
 #define	IPG_RFI_RSVD_MASK			0xFFFF00FFFFFFFFFF
 #define	IPG_RFI_FRAGADDR			0x000000FFFFFFFFFF
-#define	IPG_RFI_FRAGLEN			0xFFFF000000000000LL
+#define	IPG_RFI_FRAGLEN				0xFFFF000000000000LL
 
 /* I/O Register masks. */
 
@@ -254,37 +254,37 @@ enum ipg_regs {
 
 /* Statistics Mask */
 #define	IPG_SM_ALL					0x0FFFFFFF
-#define	IPG_SM_OCTETRCVOK_FRAMESRCVDOK		0x00000001
-#define	IPG_SM_MCSTOCTETRCVDOK_MCSTFRAMESRCVDOK	0x00000002
-#define	IPG_SM_BCSTOCTETRCVDOK_BCSTFRAMESRCVDOK	0x00000004
+#define	IPG_SM_OCTETRCVOK_FRAMESRCVDOK			0x00000001
+#define	IPG_SM_MCSTOCTETRCVDOK_MCSTFRAMESRCVDOK		0x00000002
+#define	IPG_SM_BCSTOCTETRCVDOK_BCSTFRAMESRCVDOK		0x00000004
 #define	IPG_SM_RXJUMBOFRAMES				0x00000008
 #define	IPG_SM_TCPCHECKSUMERRORS			0x00000010
-#define	IPG_SM_IPCHECKSUMERRORS			0x00000020
+#define	IPG_SM_IPCHECKSUMERRORS				0x00000020
 #define	IPG_SM_UDPCHECKSUMERRORS			0x00000040
 #define	IPG_SM_MACCONTROLFRAMESRCVD			0x00000080
 #define	IPG_SM_FRAMESTOOLONGERRORS			0x00000100
 #define	IPG_SM_INRANGELENGTHERRORS			0x00000200
 #define	IPG_SM_FRAMECHECKSEQERRORS			0x00000400
 #define	IPG_SM_FRAMESLOSTRXERRORS			0x00000800
-#define	IPG_SM_OCTETXMTOK_FRAMESXMTOK		0x00001000
-#define	IPG_SM_MCSTOCTETXMTOK_MCSTFRAMESXMTDOK	0x00002000
-#define	IPG_SM_BCSTOCTETXMTOK_BCSTFRAMESXMTDOK	0x00004000
+#define	IPG_SM_OCTETXMTOK_FRAMESXMTOK			0x00001000
+#define	IPG_SM_MCSTOCTETXMTOK_MCSTFRAMESXMTDOK		0x00002000
+#define	IPG_SM_BCSTOCTETXMTOK_BCSTFRAMESXMTDOK		0x00004000
 #define	IPG_SM_FRAMESWDEFERREDXMT			0x00008000
-#define	IPG_SM_LATECOLLISIONS			0x00010000
-#define	IPG_SM_MULTICOLFRAMES			0x00020000
-#define	IPG_SM_SINGLECOLFRAMES			0x00040000
+#define	IPG_SM_LATECOLLISIONS				0x00010000
+#define	IPG_SM_MULTICOLFRAMES				0x00020000
+#define	IPG_SM_SINGLECOLFRAMES				0x00040000
 #define	IPG_SM_TXJUMBOFRAMES				0x00080000
 #define	IPG_SM_CARRIERSENSEERRORS			0x00100000
 #define	IPG_SM_MACCONTROLFRAMESXMTD			0x00200000
 #define	IPG_SM_FRAMESABORTXSCOLLS			0x00400000
-#define	IPG_SM_FRAMESWEXDEFERAL			0x00800000
+#define	IPG_SM_FRAMESWEXDEFERAL				0x00800000
 
 /* Countdown */
 #define	IPG_CD_RSVD_MASK		0x0700FFFF
 #define	IPG_CD_COUNT			0x0000FFFF
-#define	IPG_CD_COUNTDOWNSPEED	0x01000000
+#define	IPG_CD_COUNTDOWNSPEED		0x01000000
 #define	IPG_CD_COUNTDOWNMODE		0x02000000
-#define	IPG_CD_COUNTINTENABLED	0x04000000
+#define	IPG_CD_COUNTINTENABLED		0x04000000
 
 /* TxDMABurstThresh */
 #define IPG_TB_RSVD_MASK                0xFF
@@ -653,15 +653,28 @@ enum ipg_regs {
  * Miscellaneous macros.
  */
 
-/* Marco for printing debug statements. */
+/* Macros for printing debug statements. */
 #ifdef IPG_DEBUG
-#  define IPG_DEBUG_MSG(args...)
-#  define IPG_DDEBUG_MSG(args...) printk(KERN_DEBUG "IPG: " args)
+#  define IPG_DEBUG_MSG(fmt, args...)			\
+do {							\
+	if (0)						\
+		printk(KERN_DEBUG "IPG: " fmt, ##args);	\
+} while (0)
+#  define IPG_DDEBUG_MSG(fmt, args...)			\
+	printk(KERN_DEBUG "IPG: " fmt, ##args)
 #  define IPG_DUMPRFDLIST(args) ipg_dump_rfdlist(args)
 #  define IPG_DUMPTFDLIST(args) ipg_dump_tfdlist(args)
 #else
-#  define IPG_DEBUG_MSG(args...)
-#  define IPG_DDEBUG_MSG(args...)
+#  define IPG_DEBUG_MSG(fmt, args...)			\
+do {							\
+	if (0)						\
+		printk(KERN_DEBUG "IPG: " fmt, ##args);	\
+} while (0)
+#  define IPG_DDEBUG_MSG(fmt, args...)			\
+do {							\
+	if (0)						\
+		printk(KERN_DEBUG "IPG: " fmt, ##args);	\
+} while (0)
 #  define IPG_DUMPRFDLIST(args)
 #  define IPG_DUMPTFDLIST(args)
 #endif


