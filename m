From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (3/25) sk98: remove #define of net_device
Date: Mon, 15 Nov 2004 15:21:58 -0800
Message-ID: <20041115152158.0b5dad55@zqx3.pdx.osdl.net>
References: <20041115150910.0f3b8498@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Mirko Lindner <demon@pro-linux.de>, netdev@oss.sgi.com,
        Christoph
 Hellwig <hch@infradead.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <20041115150910.0f3b8498@zqx3.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Get rid of obfuscating #define of net_device.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

diff -Nru a/drivers/net/sk98lin/h/skdrv1st.h b/drivers/net/sk98lin/h/skdrv1st.h
--- a/drivers/net/sk98lin/h/skdrv1st.h	2004-11-15 11:22:11 -08:00
+++ b/drivers/net/sk98lin/h/skdrv1st.h	2004-11-15 11:22:11 -08:00
@@ -96,9 +96,6 @@
 #define SK_BIG_ENDIAN
 #endif
 
-#define SK_NET_DEVICE	net_device
-
-
 /* we use gethrtime(), return unit: nanoseconds */
 #define SK_TICKS_PER_SEC	100
 
diff -Nru a/drivers/net/sk98lin/h/skdrv2nd.h b/drivers/net/sk98lin/h/skdrv2nd.h
--- a/drivers/net/sk98lin/h/skdrv2nd.h	2004-11-15 11:22:11 -08:00
+++ b/drivers/net/sk98lin/h/skdrv2nd.h	2004-11-15 11:22:11 -08:00
@@ -70,7 +70,7 @@
 extern int		SkDrvLeaveDiagMode(SK_AC *pAc);
 #endif
 
-extern int	SkGeXmit(struct sk_buff *skb, struct SK_NET_DEVICE *dev);
+extern int	SkGeXmit(struct sk_buff *skb, struct net_device *dev);
 #ifdef CONFIG_PROC_FS
 extern struct proc_dir_entry *SkGeProcCreate(struct net_device *dev);
 extern void	SkGeProcRemove(struct proc_dir_entry *pe);
@@ -408,7 +408,7 @@
 	SK_U32		AllocFlag;	/* flag allocation of resources */
 	struct pci_dev	*PciDev;	/* for access to pci config space */
 	SK_U32		PciDevId;	/* pci device id */
-	struct SK_NET_DEVICE	*dev[2];	/* pointer to device struct */
+	struct net_device *dev[2];	/* pointer to device struct */
 	char		Name[30];	/* driver name */
 
 	int		RxBufSize;	/* length of receive buffers */
diff -Nru a/drivers/net/sk98lin/skge.c b/drivers/net/sk98lin/skge.c
--- a/drivers/net/sk98lin/skge.c	2004-11-15 11:22:11 -08:00
+++ b/drivers/net/sk98lin/skge.c	2004-11-15 11:22:11 -08:00
@@ -189,20 +189,20 @@
  *
  ******************************************************************************/
 
-static void	FreeResources(struct SK_NET_DEVICE *dev);
-static int	SkGeBoardInit(struct SK_NET_DEVICE *dev, SK_AC *pAC);
+static void	FreeResources(struct net_device *dev);
+static int	SkGeBoardInit(struct net_device *dev, SK_AC *pAC);
 static SK_BOOL	BoardAllocMem(SK_AC *pAC);
 static void	BoardFreeMem(SK_AC *pAC);
 static void	BoardInitMem(SK_AC *pAC);
 static void	SetupRing(SK_AC*, void*, uintptr_t, RXD**, RXD**, RXD**, int*, SK_BOOL);
 static SkIsrRetVar	SkGeIsr(int irq, void *dev_id, struct pt_regs *ptregs);
 static SkIsrRetVar	SkGeIsrOnePort(int irq, void *dev_id, struct pt_regs *ptregs);
-static int	SkGeOpen(struct SK_NET_DEVICE *dev);
-static int	SkGeClose(struct SK_NET_DEVICE *dev);
-static int	SkGeSetMacAddr(struct SK_NET_DEVICE *dev, void *p);
-static void	SkGeSetRxMode(struct SK_NET_DEVICE *dev);
-static struct	net_device_stats *SkGeStats(struct SK_NET_DEVICE *dev);
-static int	SkGeIoctl(struct SK_NET_DEVICE *dev, struct ifreq *rq, int cmd);
+static int	SkGeOpen(struct net_device *dev);
+static int	SkGeClose(struct net_device *dev);
+static int	SkGeSetMacAddr(struct net_device *dev, void *p);
+static void	SkGeSetRxMode(struct net_device *dev);
+static struct	net_device_stats *SkGeStats(struct net_device *dev);
+static int	SkGeIoctl(struct net_device *dev, struct ifreq *rq, int cmd);
 static void	GetConfiguration(SK_AC*);
 static void	ProductStr(SK_AC*);
 static int	XmitFrame(SK_AC*, TX_PORT*, struct sk_buff*);
@@ -214,7 +214,7 @@
 static void	ClearTxIrq(SK_AC*, int, int);
 static void	ClearRxRing(SK_AC*, RX_PORT*);
 static void	ClearTxRing(SK_AC*, TX_PORT*);
-static int	SkGeChangeMtu(struct SK_NET_DEVICE *dev, int new_mtu);
+static int	SkGeChangeMtu(struct net_device *dev, int new_mtu);
 static void	PortReInitBmu(SK_AC*, int);
 static int	SkGeIocMib(DEV_NET*, unsigned int, int);
 static int	SkGeInitPCI(SK_AC *pAC);
@@ -266,7 +266,7 @@
  */
 int SkGeInitPCI(SK_AC *pAC)
 {
-	struct SK_NET_DEVICE *dev = pAC->dev[0];
+	struct net_device *dev = pAC->dev[0];
 	struct pci_dev *pdev = pAC->PciDev;
 	int retval;
 
@@ -326,7 +326,7 @@
  * Returns: N/A
  *	
  */
-static void FreeResources(struct SK_NET_DEVICE *dev)
+static void FreeResources(struct net_device *dev)
 {
 SK_U32 AllocFlag;
 DEV_NET		*pNet;
@@ -471,7 +471,7 @@
  *	0, if everything is ok
  *	!=0, on error
  */
-static int __init SkGeBoardInit(struct SK_NET_DEVICE *dev, SK_AC *pAC)
+static int __init SkGeBoardInit(struct net_device *dev, SK_AC *pAC)
 {
 short	i;
 unsigned long Flags;
@@ -874,7 +874,7 @@
  */
 static SkIsrRetVar SkGeIsr(int irq, void *dev_id, struct pt_regs *ptregs)
 {
-struct SK_NET_DEVICE *dev = (struct SK_NET_DEVICE *)dev_id;
+struct net_device *dev = (struct net_device *)dev_id;
 DEV_NET		*pNet;
 SK_AC		*pAC;
 SK_U32		IntSrc;		/* interrupts source register contents */	
@@ -1023,7 +1023,7 @@
  */
 static SkIsrRetVar SkGeIsrOnePort(int irq, void *dev_id, struct pt_regs *ptregs)
 {
-struct SK_NET_DEVICE *dev = (struct SK_NET_DEVICE *)dev_id;
+struct net_device *dev = (struct net_device *)dev_id;
 DEV_NET		*pNet;
 SK_AC		*pAC;
 SK_U32		IntSrc;		/* interrupts source register contents */	
@@ -1154,7 +1154,7 @@
  *	!= 0 on error
  */
 static int SkGeOpen(
-struct SK_NET_DEVICE	*dev)
+struct net_device	*dev)
 {
 	DEV_NET			*pNet;
 	SK_AC			*pAC;
@@ -1269,7 +1269,7 @@
  *	error code - on error
  */
 static int SkGeClose(
-struct SK_NET_DEVICE	*dev)
+struct net_device	*dev)
 {
 	DEV_NET		*pNet;
 	DEV_NET		*newPtrNet;
@@ -1398,7 +1398,7 @@
  * WARNING: returning 1 in 'tbusy' case caused system crashes (double
  *	allocated skb's) !!!
  */
-int SkGeXmit(struct sk_buff *skb, struct SK_NET_DEVICE *dev)
+int SkGeXmit(struct sk_buff *skb, struct net_device *dev)
 {
 DEV_NET		*pNet;
 SK_AC		*pAC;
@@ -2497,7 +2497,7 @@
  *	0, if everything is ok
  *	!=0, on error
  */
-static int SkGeSetMacAddr(struct SK_NET_DEVICE *dev, void *p)
+static int SkGeSetMacAddr(struct net_device *dev, void *p)
 {
 
 DEV_NET *pNet = netdev_priv(dev);
@@ -2543,7 +2543,7 @@
  *	0, if everything is ok
  *	!=0, on error
  */
-static void SkGeSetRxMode(struct SK_NET_DEVICE *dev)
+static void SkGeSetRxMode(struct net_device *dev)
 {
 
 DEV_NET		*pNet;
@@ -2617,7 +2617,7 @@
  *	0, if everything is ok
  *	!=0, on error
  */
-static int SkGeChangeMtu(struct SK_NET_DEVICE *dev, int NewMtu)
+static int SkGeChangeMtu(struct net_device *dev, int NewMtu)
 {
 DEV_NET		*pNet;
 DEV_NET		*pOtherNet;
@@ -2855,7 +2855,7 @@
  * Returns:
  *	pointer to the statistic structure.
  */
-static struct net_device_stats *SkGeStats(struct SK_NET_DEVICE *dev)
+static struct net_device_stats *SkGeStats(struct net_device *dev)
 {
 DEV_NET *pNet = netdev_priv(dev);
 SK_AC	*pAC = pNet->pAC;
@@ -2939,7 +2939,7 @@
  *	0, if everything is ok
  *	!=0, on error
  */
-static int SkGeIoctl(struct SK_NET_DEVICE *dev, struct ifreq *rq, int cmd)
+static int SkGeIoctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
 DEV_NET		*pNet;
 SK_AC		*pAC;
@@ -4676,7 +4676,7 @@
 SK_AC   *pAC,		/* pointer to adapter context   */
 int      devNbr)	/* what device is to be handled */
 {
-	struct SK_NET_DEVICE *dev;
+	struct net_device *dev;
 
 	dev = pAC->dev[devNbr];
 
@@ -4707,7 +4707,7 @@
 SK_AC   *pAC,		/* pointer to adapter context   */
 int      devNbr)	/* what device is to be handled */
 {
-	struct SK_NET_DEVICE *dev;
+	struct net_device *dev;
 
 	dev = pAC->dev[devNbr];
 
