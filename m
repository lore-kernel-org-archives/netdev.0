From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (6/25) sk98: get rid of #define's for C99 types
Date: Mon, 15 Nov 2004 15:22:14 -0800
Message-ID: <20041115152214.1eb0da66@zqx3.pdx.osdl.net>
References: <20041115150910.0f3b8498@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Mirko Lindner <demon@pro-linux.de>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <20041115150910.0f3b8498@zqx3.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Get rid of #define's for type's and use proper kernel types.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/sk98lin/h/skdrv1st.h b/drivers/net/sk98lin/h/skdrv1st.h
--- a/drivers/net/sk98lin/h/skdrv1st.h	2004-11-15 11:24:00 -08:00
+++ b/drivers/net/sk98lin/h/skdrv1st.h	2004-11-15 11:24:00 -08:00
@@ -123,18 +123,6 @@
 #define SK_IN16(b,a,pv)		(*(pv) = readw((b)+(a)))
 #define SK_IN32(b,a,pv)		(*(pv) = readl((b)+(a)))
 
-#define int8_t		char
-#define int16_t		short
-#define int32_t		long
-#define int64_t		long long
-#define uint8_t		u_char
-#define uint16_t	u_short
-#define uint32_t	u_long
-#define uint64_t	unsigned long long
-#define t_scalar_t	int
-#define t_uscalar_t	unsigned int
-#define uintptr_t	unsigned long
-
 #ifdef DEBUG
 #define SK_DBG_PRINTF		printk
 #ifndef SK_DEBUG_CHKMOD
diff -Nru a/drivers/net/sk98lin/skge.c b/drivers/net/sk98lin/skge.c
--- a/drivers/net/sk98lin/skge.c	2004-11-15 11:24:00 -08:00
+++ b/drivers/net/sk98lin/skge.c	2004-11-15 11:24:00 -08:00
@@ -194,7 +194,7 @@
 static SK_BOOL	BoardAllocMem(SK_AC *pAC);
 static void	BoardFreeMem(SK_AC *pAC);
 static void	BoardInitMem(SK_AC *pAC);
-static void	SetupRing(SK_AC*, void*, uintptr_t, RXD**, RXD**, RXD**, int*, SK_BOOL);
+static void	SetupRing(SK_AC*, void*, u64, RXD**, RXD**, RXD**, int*, SK_BOOL);
 static SkIsrRetVar	SkGeIsr(int irq, void *dev_id, struct pt_regs *ptregs);
 static SkIsrRetVar	SkGeIsrOnePort(int irq, void *dev_id, struct pt_regs *ptregs);
 static int	SkGeOpen(struct net_device *dev);
@@ -251,8 +251,8 @@
 extern  struct ethtool_ops SkGeEthtoolOps;
 
 /* local variables **********************************************************/
-static uintptr_t TxQueueAddr[SK_MAX_MACS][2] = {{0x680, 0x600},{0x780, 0x700}};
-static uintptr_t RxQueueAddr[SK_MAX_MACS] = {0x400, 0x480};
+static u32 TxQueueAddr[SK_MAX_MACS][2] = {{0x680, 0x600},{0x780, 0x700}};
+static u32 RxQueueAddr[SK_MAX_MACS] = {0x400, 0x480};
 
 /*****************************************************************************
  *
@@ -763,7 +763,7 @@
 static void SetupRing(
 SK_AC		*pAC,
 void		*pMemArea,	/* a pointer to the memory area for the ring */
-uintptr_t	VMemArea,	/* the virtual bus address of the memory area */
+u64		VMemArea,	/* the virtual bus address of the memory area */
 RXD		**ppRingHead,	/* address where the head should be written */
 RXD		**ppRingTail,	/* address where the tail should be written */
 RXD		**ppRingPrev,	/* address where the tail should be written */
@@ -776,7 +776,7 @@
 RXD	*pDescr;	/* pointer to a descriptor (receive or transmit) */
 RXD	*pNextDescr;	/* pointer to the next descriptor */
 RXD	*pPrevDescr;	/* pointer to the previous descriptor */
-uintptr_t VNextDescr;	/* the virtual bus address of the next descriptor */
+u64	VNextDescr;	/* the virtual bus address of the next descriptor */
 
 	if (IsTx == SK_TRUE) {
 		DescrSize = (((sizeof(TXD) - 1) / DESCR_ALIGN) + 1) *
@@ -839,22 +839,22 @@
 
 	/* set address of first descriptor of ring in BMU */
 	SK_OUT32(pAC->IoBase, TxQueueAddr[PortIndex][TX_PRIO_LOW]+ Q_DA_L,
-		(uint32_t)(((caddr_t)
+		(u32)(((caddr_t)
 		(pAC->TxPort[PortIndex][TX_PRIO_LOW].pTxdRingHead) -
 		pAC->TxPort[PortIndex][TX_PRIO_LOW].pTxDescrRing +
 		pAC->TxPort[PortIndex][TX_PRIO_LOW].VTxDescrRing) &
 		0xFFFFFFFF));
 	SK_OUT32(pAC->IoBase, TxQueueAddr[PortIndex][TX_PRIO_LOW]+ Q_DA_H,
-		(uint32_t)(((caddr_t)
+		(u32)(((caddr_t)
 		(pAC->TxPort[PortIndex][TX_PRIO_LOW].pTxdRingHead) -
 		pAC->TxPort[PortIndex][TX_PRIO_LOW].pTxDescrRing +
 		pAC->TxPort[PortIndex][TX_PRIO_LOW].VTxDescrRing) >> 32));
 	SK_OUT32(pAC->IoBase, RxQueueAddr[PortIndex]+Q_DA_L,
-		(uint32_t)(((caddr_t)(pAC->RxPort[PortIndex].pRxdRingHead) -
+		(u32)(((caddr_t)(pAC->RxPort[PortIndex].pRxdRingHead) -
 		pAC->RxPort[PortIndex].pRxDescrRing +
 		pAC->RxPort[PortIndex].VRxDescrRing) & 0xFFFFFFFF));
 	SK_OUT32(pAC->IoBase, RxQueueAddr[PortIndex]+Q_DA_H,
-		(uint32_t)(((caddr_t)(pAC->RxPort[PortIndex].pRxdRingHead) -
+		(u32)(((caddr_t)(pAC->RxPort[PortIndex].pRxdRingHead) -
 		pAC->RxPort[PortIndex].pRxDescrRing +
 		pAC->RxPort[PortIndex].VRxDescrRing) >> 32));
 } /* PortReInitBmu */
