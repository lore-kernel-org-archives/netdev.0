From: Sakari Ailus <sakari.ailus@iki.fi>
Subject: [PATCH 1/3] tlan: Code cleanup: checkpatch.pl is relatively happy now.
Date: Thu,  6 Jan 2011 20:50:15 +0200
Message-ID: <1294339817-31434-1-git-send-email-sakari.ailus@iki.fi>
References: <4D260ED0.5040301@iki.fi>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-68.nebula.fi ([83.145.220.68]:53448 "EHLO
	smtp-68.nebula.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751153Ab1AFTBN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Jan 2011 14:01:13 -0500
Received: from hillosipuli.localdomain (nblzone-211-213.nblnetworks.fi [83.145.211.213])
	(using TLSv1 with cipher ADH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by smtp-68.nebula.fi (Postfix) with ESMTP id BC6E243F0AFF
	for <netdev@vger.kernel.org>; Thu,  6 Jan 2011 20:50:17 +0200 (EET)
Received: from retiisi.localdomain (unknown [192.168.3.254])
	by hillosipuli.localdomain (Postfix) with ESMTP id A21E26009B
	for <netdev@vger.kernel.org>; Thu,  6 Jan 2011 20:50:16 +0200 (EET)
Received: from masiina.localdomain (masiina.localdomain [192.168.1.1])
	by retiisi.localdomain (Postfix) with ESMTP id 4195920D07
	for <netdev@vger.kernel.org>; Thu,  6 Jan 2011 20:50:17 +0200 (EET)
Received: from masiina.localdomain (localhost [127.0.0.1])
	by masiina.localdomain (8.14.3/8.14.3/Debian-5+lenny1) with ESMTP id p06IoHxK031470
	for <netdev@vger.kernel.org>; Thu, 6 Jan 2011 20:50:17 +0200
Received: (from sakke@localhost)
	by masiina.localdomain (8.14.3/8.14.3/Submit) id p06IoH0f031469
	for netdev@vger.kernel.org; Thu, 6 Jan 2011 20:50:17 +0200
In-Reply-To: <4D260ED0.5040301@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Remove CamelCase.
- Convert hexadecimals to lower case.
- Remove useless comments. Tlan driver contained a name of the function at
  the end of it in a comment. Remove those comments.
- Remove local typedefs. Use real types instead of typedefs in code.
- Resolve space issues and reindent.
- One warning remain, it's a case where printing a single line involves a
  number of printk()s.

Signed-off-by: Sakari Ailus <sakari.ailus@iki.fi>
---
 drivers/net/tlan.c | 3703 ++++++++++++++++++++++++++--------------------------
 drivers/net/tlan.h |  192 ++--
 2 files changed, 1967 insertions(+), 1928 deletions(-)

diff --git a/drivers/net/tlan.c b/drivers/net/tlan.c
index f8e463c..57380b1 100644
--- a/drivers/net/tlan.c
+++ b/drivers/net/tlan.c
@@ -63,45 +63,45 @@
  *			     - Other minor stuff
  *
  *	v1.4 Feb 10, 2000    - Updated with more changes required after Dave's
- *	                       network cleanup in 2.3.43pre7 (Tigran & myself)
- *	                     - Minor stuff.
+ *			       network cleanup in 2.3.43pre7 (Tigran & myself)
+ *			     - Minor stuff.
  *
- *	v1.5 March 22, 2000  - Fixed another timer bug that would hang the driver
- *			       if no cable/link were present.
+ *	v1.5 March 22, 2000  - Fixed another timer bug that would hang the
+ *			       driver if no cable/link were present.
  *			     - Cosmetic changes.
  *			     - TODO: Port completely to new PCI/DMA API
- *			     	     Auto-Neg fallback.
- *
- * 	v1.6 April 04, 2000  - Fixed driver support for kernel-parameters. Haven't
- * 			       tested it though, as the kernel support is currently
- * 			       broken (2.3.99p4p3).
- * 			     - Updated tlan.txt accordingly.
- * 			     - Adjusted minimum/maximum frame length.
- * 			     - There is now a TLAN website up at
- * 			       http://hp.sourceforge.net/ 
- *
- * 	v1.7 April 07, 2000  - Started to implement custom ioctls. Driver now
- * 			       reports PHY information when used with Donald
- * 			       Beckers userspace MII diagnostics utility.
- *
- * 	v1.8 April 23, 2000  - Fixed support for forced speed/duplex settings.
- * 			     - Added link information to Auto-Neg and forced
- * 			       modes. When NIC operates with auto-neg the driver
- * 			       will report Link speed & duplex modes as well as
- * 			       link partner abilities. When forced link is used,
- * 			       the driver will report status of the established
- * 			       link.
- * 			       Please read tlan.txt for additional information.
- * 			     - Removed call to check_region(), and used
- * 			       return value of request_region() instead.
+ *				     Auto-Neg fallback.
+ *
+ *	v1.6 April 04, 2000  - Fixed driver support for kernel-parameters.
+ *			       Haven't tested it though, as the kernel support
+ *			       is currently broken (2.3.99p4p3).
+ *			     - Updated tlan.txt accordingly.
+ *			     - Adjusted minimum/maximum frame length.
+ *			     - There is now a TLAN website up at
+ *			       http://hp.sourceforge.net/
+ *
+ *	v1.7 April 07, 2000  - Started to implement custom ioctls. Driver now
+ *			       reports PHY information when used with Donald
+ *			       Beckers userspace MII diagnostics utility.
+ *
+ *	v1.8 April 23, 2000  - Fixed support for forced speed/duplex settings.
+ *			     - Added link information to Auto-Neg and forced
+ *			       modes. When NIC operates with auto-neg the driver
+ *			       will report Link speed & duplex modes as well as
+ *			       link partner abilities. When forced link is used,
+ *			       the driver will report status of the established
+ *			       link.
+ *			       Please read tlan.txt for additional information.
+ *			     - Removed call to check_region(), and used
+ *			       return value of request_region() instead.
  *
  *	v1.8a May 28, 2000   - Minor updates.
  *
  *	v1.9 July 25, 2000   - Fixed a few remaining Full-Duplex issues.
- *	                     - Updated with timer fixes from Andrew Morton.
- *	                     - Fixed module race in TLan_Open.
- *	                     - Added routine to monitor PHY status.
- *	                     - Added activity led support for Proliant devices.
+ *			     - Updated with timer fixes from Andrew Morton.
+ *			     - Fixed module race in TLan_Open.
+ *			     - Added routine to monitor PHY status.
+ *			     - Added activity led support for Proliant devices.
  *
  *	v1.10 Aug 30, 2000   - Added support for EISA based tlan controllers
  *			       like the Compaq NetFlex3/E.
@@ -111,8 +111,8 @@
  *			       hardware probe is done with kernel API and
  *			       TLan_EisaProbe.
  *			     - Adjusted debug information for probing.
- *			     - Fixed bug that would cause general debug information
- *			       to be printed after driver removal.
+ *			     - Fixed bug that would cause general debug
+ *			       information to be printed after driver removal.
  *			     - Added transmit timeout handling.
  *			     - Fixed OOM return values in tlan_probe.
  *			     - Fixed possible mem leak in tlan_exit
@@ -136,8 +136,8 @@
  *
  *	v1.12 Oct 12, 2000   - Minor fixes (memleak, init, etc.)
  *
- * 	v1.13 Nov 28, 2000   - Stop flooding console with auto-neg issues
- * 			       when link can't be established.
+ *	v1.13 Nov 28, 2000   - Stop flooding console with auto-neg issues
+ *			       when link can't be established.
  *			     - Added the bbuf option as a kernel parameter.
  *			     - Fixed ioaddr probe bug.
  *			     - Fixed stupid deadlock with MII interrupts.
@@ -147,28 +147,29 @@
  *			       TLAN v1.0 silicon. This needs to be investigated
  *			       further.
  *
- * 	v1.14 Dec 16, 2000   - Added support for servicing multiple frames per.
- * 			       interrupt. Thanks goes to
- * 			       Adam Keys <adam@ti.com>
- * 			       Denis Beaudoin <dbeaudoin@ti.com>
- * 			       for providing the patch.
- * 			     - Fixed auto-neg output when using multiple
- * 			       adapters.
- * 			     - Converted to use new taskq interface.
+ *	v1.14 Dec 16, 2000   - Added support for servicing multiple frames per.
+ *			       interrupt. Thanks goes to
+ *			       Adam Keys <adam@ti.com>
+ *			       Denis Beaudoin <dbeaudoin@ti.com>
+ *			       for providing the patch.
+ *			     - Fixed auto-neg output when using multiple
+ *			       adapters.
+ *			     - Converted to use new taskq interface.
  *
- * 	v1.14a Jan 6, 2001   - Minor adjustments (spinlocks, etc.)
+ *	v1.14a Jan 6, 2001   - Minor adjustments (spinlocks, etc.)
  *
  *	Samuel Chessman <chessman@tux.org> New Maintainer!
  *
  *	v1.15 Apr 4, 2002    - Correct operation when aui=1 to be
- *	                       10T half duplex no loopback
- *	                       Thanks to Gunnar Eikman
+ *			       10T half duplex no loopback
+ *			       Thanks to Gunnar Eikman
  *
  *	Sakari Ailus <sakari.ailus@iki.fi>:
  *
  *	v1.15a Dec 15 2008   - Remove bbuf support, it doesn't work anyway.
+ *	v1.16  Jan 6  2011   - Make checkpatch.pl happy.
  *
- *******************************************************************************/
+ ******************************************************************************/
 
 #include <linux/module.h>
 #include <linux/init.h>
@@ -185,13 +186,11 @@
 
 #include "tlan.h"
 
-typedef u32 (TLanIntVectorFunc)( struct net_device *, u16 );
-
 
 /* For removing EISA devices */
-static	struct net_device	*TLan_Eisa_Devices;
+static	struct net_device	*tlan_eisa_devices;
 
-static	int		TLanDevicesInstalled;
+static	int		tlan_devices_installed;
 
 /* Set speed, duplex and aui settings */
 static  int aui[MAX_TLAN_BOARDS];
@@ -202,7 +201,8 @@ module_param_array(aui, int, NULL, 0);
 module_param_array(duplex, int, NULL, 0);
 module_param_array(speed, int, NULL, 0);
 MODULE_PARM_DESC(aui, "ThunderLAN use AUI port(s) (0-1)");
-MODULE_PARM_DESC(duplex, "ThunderLAN duplex setting(s) (0-default, 1-half, 2-full)");
+MODULE_PARM_DESC(duplex,
+		 "ThunderLAN duplex setting(s) (0-default, 1-half, 2-full)");
 MODULE_PARM_DESC(speed, "ThunderLAN port speen setting(s) (0,10,100)");
 
 MODULE_AUTHOR("Maintainer: Samuel Chessman <chessman@tux.org>");
@@ -218,139 +218,144 @@ static  int		debug;
 module_param(debug, int, 0);
 MODULE_PARM_DESC(debug, "ThunderLAN debug mask");
 
-static	const char TLanSignature[] = "TLAN";
-static  const char tlan_banner[] = "ThunderLAN driver v1.15a\n";
+static	const char tlan_signature[] = "TLAN";
+static  const char tlan_banner[] = "ThunderLAN driver v1.16\n";
 static  int tlan_have_pci;
 static  int tlan_have_eisa;
 
-static const char *media[] = {
-	"10BaseT-HD ", "10BaseT-FD ","100baseTx-HD ",
-	"100baseTx-FD", "100baseT4", NULL
+static const char * const media[] = {
+	"10BaseT-HD", "10BaseT-FD", "100baseTx-HD",
+	"100BaseTx-FD", "100BaseT4", NULL
 };
 
 static struct board {
-	const char	*deviceLabel;
-	u32	   	flags;
-	u16	   	addrOfs;
+	const char	*device_label;
+	u32		flags;
+	u16		addr_ofs;
 } board_info[] = {
 	{ "Compaq Netelligent 10 T PCI UTP", TLAN_ADAPTER_ACTIVITY_LED, 0x83 },
-	{ "Compaq Netelligent 10/100 TX PCI UTP", TLAN_ADAPTER_ACTIVITY_LED, 0x83 },
+	{ "Compaq Netelligent 10/100 TX PCI UTP",
+	  TLAN_ADAPTER_ACTIVITY_LED, 0x83 },
 	{ "Compaq Integrated NetFlex-3/P", TLAN_ADAPTER_NONE, 0x83 },
 	{ "Compaq NetFlex-3/P",
 	  TLAN_ADAPTER_UNMANAGED_PHY | TLAN_ADAPTER_BIT_RATE_PHY, 0x83 },
 	{ "Compaq NetFlex-3/P", TLAN_ADAPTER_NONE, 0x83 },
 	{ "Compaq Netelligent Integrated 10/100 TX UTP",
 	  TLAN_ADAPTER_ACTIVITY_LED, 0x83 },
-	{ "Compaq Netelligent Dual 10/100 TX PCI UTP", TLAN_ADAPTER_NONE, 0x83 },
-	{ "Compaq Netelligent 10/100 TX Embedded UTP", TLAN_ADAPTER_NONE, 0x83 },
+	{ "Compaq Netelligent Dual 10/100 TX PCI UTP",
+	  TLAN_ADAPTER_NONE, 0x83 },
+	{ "Compaq Netelligent 10/100 TX Embedded UTP",
+	  TLAN_ADAPTER_NONE, 0x83 },
 	{ "Olicom OC-2183/2185", TLAN_ADAPTER_USE_INTERN_10, 0x83 },
-	{ "Olicom OC-2325", TLAN_ADAPTER_UNMANAGED_PHY, 0xF8 },
-	{ "Olicom OC-2326", TLAN_ADAPTER_USE_INTERN_10, 0xF8 },
+	{ "Olicom OC-2325", TLAN_ADAPTER_UNMANAGED_PHY, 0xf8 },
+	{ "Olicom OC-2326", TLAN_ADAPTER_USE_INTERN_10, 0xf8 },
 	{ "Compaq Netelligent 10/100 TX UTP", TLAN_ADAPTER_ACTIVITY_LED, 0x83 },
-	{ "Compaq Netelligent 10 T/2 PCI UTP/Coax", TLAN_ADAPTER_NONE, 0x83 },
+	{ "Compaq Netelligent 10 T/2 PCI UTP/coax", TLAN_ADAPTER_NONE, 0x83 },
 	{ "Compaq NetFlex-3/E",
-	  TLAN_ADAPTER_ACTIVITY_LED | 	/* EISA card */
+	  TLAN_ADAPTER_ACTIVITY_LED |	/* EISA card */
 	  TLAN_ADAPTER_UNMANAGED_PHY | TLAN_ADAPTER_BIT_RATE_PHY, 0x83 },
-	{ "Compaq NetFlex-3/E", TLAN_ADAPTER_ACTIVITY_LED, 0x83 }, /* EISA card */
+	{ "Compaq NetFlex-3/E",
+	  TLAN_ADAPTER_ACTIVITY_LED, 0x83 }, /* EISA card */
 };
 
 static DEFINE_PCI_DEVICE_TABLE(tlan_pci_tbl) = {
 	{ PCI_VENDOR_ID_COMPAQ, PCI_DEVICE_ID_COMPAQ_NETEL10,
-		PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
+	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0 },
 	{ PCI_VENDOR_ID_COMPAQ, PCI_DEVICE_ID_COMPAQ_NETEL100,
-		PCI_ANY_ID, PCI_ANY_ID, 0, 0, 1 },
+	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, 1 },
 	{ PCI_VENDOR_ID_COMPAQ, PCI_DEVICE_ID_COMPAQ_NETFLEX3I,
-		PCI_ANY_ID, PCI_ANY_ID, 0, 0, 2 },
+	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, 2 },
 	{ PCI_VENDOR_ID_COMPAQ, PCI_DEVICE_ID_COMPAQ_THUNDER,
-		PCI_ANY_ID, PCI_ANY_ID, 0, 0, 3 },
+	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, 3 },
 	{ PCI_VENDOR_ID_COMPAQ, PCI_DEVICE_ID_COMPAQ_NETFLEX3B,
-		PCI_ANY_ID, PCI_ANY_ID, 0, 0, 4 },
+	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, 4 },
 	{ PCI_VENDOR_ID_COMPAQ, PCI_DEVICE_ID_COMPAQ_NETEL100PI,
-		PCI_ANY_ID, PCI_ANY_ID, 0, 0, 5 },
+	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, 5 },
 	{ PCI_VENDOR_ID_COMPAQ, PCI_DEVICE_ID_COMPAQ_NETEL100D,
-		PCI_ANY_ID, PCI_ANY_ID, 0, 0, 6 },
+	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, 6 },
 	{ PCI_VENDOR_ID_COMPAQ, PCI_DEVICE_ID_COMPAQ_NETEL100I,
-		PCI_ANY_ID, PCI_ANY_ID, 0, 0, 7 },
+	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, 7 },
 	{ PCI_VENDOR_ID_OLICOM, PCI_DEVICE_ID_OLICOM_OC2183,
-		PCI_ANY_ID, PCI_ANY_ID, 0, 0, 8 },
+	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, 8 },
 	{ PCI_VENDOR_ID_OLICOM, PCI_DEVICE_ID_OLICOM_OC2325,
-		PCI_ANY_ID, PCI_ANY_ID, 0, 0, 9 },
+	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, 9 },
 	{ PCI_VENDOR_ID_OLICOM, PCI_DEVICE_ID_OLICOM_OC2326,
-		PCI_ANY_ID, PCI_ANY_ID, 0, 0, 10 },
+	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, 10 },
 	{ PCI_VENDOR_ID_COMPAQ, PCI_DEVICE_ID_NETELLIGENT_10_100_WS_5100,
-		PCI_ANY_ID, PCI_ANY_ID, 0, 0, 11 },
+	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, 11 },
 	{ PCI_VENDOR_ID_COMPAQ, PCI_DEVICE_ID_NETELLIGENT_10_T2,
-		PCI_ANY_ID, PCI_ANY_ID, 0, 0, 12 },
+	  PCI_ANY_ID, PCI_ANY_ID, 0, 0, 12 },
 	{ 0,}
 };
 MODULE_DEVICE_TABLE(pci, tlan_pci_tbl);
 
-static void	TLan_EisaProbe( void );
-static void	TLan_Eisa_Cleanup( void );
-static int      TLan_Init( struct net_device * );
-static int	TLan_Open( struct net_device *dev );
-static netdev_tx_t TLan_StartTx( struct sk_buff *, struct net_device *);
-static irqreturn_t TLan_HandleInterrupt( int, void *);
-static int	TLan_Close( struct net_device *);
-static struct	net_device_stats *TLan_GetStats( struct net_device *);
-static void	TLan_SetMulticastList( struct net_device *);
-static int	TLan_ioctl( struct net_device *dev, struct ifreq *rq, int cmd);
-static int      TLan_probe1( struct pci_dev *pdev, long ioaddr,
-			     int irq, int rev, const struct pci_device_id *ent);
-static void	TLan_tx_timeout( struct net_device *dev);
-static void	TLan_tx_timeout_work(struct work_struct *work);
-static int 	tlan_init_one( struct pci_dev *pdev, const struct pci_device_id *ent);
-
-static u32	TLan_HandleTxEOF( struct net_device *, u16 );
-static u32	TLan_HandleStatOverflow( struct net_device *, u16 );
-static u32	TLan_HandleRxEOF( struct net_device *, u16 );
-static u32	TLan_HandleDummy( struct net_device *, u16 );
-static u32	TLan_HandleTxEOC( struct net_device *, u16 );
-static u32	TLan_HandleStatusCheck( struct net_device *, u16 );
-static u32	TLan_HandleRxEOC( struct net_device *, u16 );
-
-static void	TLan_Timer( unsigned long );
-
-static void	TLan_ResetLists( struct net_device * );
-static void	TLan_FreeLists( struct net_device * );
-static void	TLan_PrintDio( u16 );
-static void	TLan_PrintList( TLanList *, char *, int );
-static void	TLan_ReadAndClearStats( struct net_device *, int );
-static void	TLan_ResetAdapter( struct net_device * );
-static void	TLan_FinishReset( struct net_device * );
-static void	TLan_SetMac( struct net_device *, int areg, char *mac );
-
-static void	TLan_PhyPrint( struct net_device * );
-static void	TLan_PhyDetect( struct net_device * );
-static void	TLan_PhyPowerDown( struct net_device * );
-static void	TLan_PhyPowerUp( struct net_device * );
-static void	TLan_PhyReset( struct net_device * );
-static void	TLan_PhyStartLink( struct net_device * );
-static void	TLan_PhyFinishAutoNeg( struct net_device * );
+static void	tlan_eisa_probe(void);
+static void	tlan_eisa_cleanup(void);
+static int      tlan_init(struct net_device *);
+static int	tlan_open(struct net_device *dev);
+static netdev_tx_t tlan_start_tx(struct sk_buff *, struct net_device *);
+static irqreturn_t tlan_handle_interrupt(int, void *);
+static int	tlan_close(struct net_device *);
+static struct	net_device_stats *tlan_get_stats(struct net_device *);
+static void	tlan_set_multicast_list(struct net_device *);
+static int	tlan_ioctl(struct net_device *dev, struct ifreq *rq, int cmd);
+static int      tlan_probe1(struct pci_dev *pdev, long ioaddr,
+			    int irq, int rev, const struct pci_device_id *ent);
+static void	tlan_tx_timeout(struct net_device *dev);
+static void	tlan_tx_timeout_work(struct work_struct *work);
+static int	tlan_init_one(struct pci_dev *pdev,
+			      const struct pci_device_id *ent);
+
+static u32	tlan_handle_tx_eof(struct net_device *, u16);
+static u32	tlan_handle_stat_overflow(struct net_device *, u16);
+static u32	tlan_handle_rx_eof(struct net_device *, u16);
+static u32	tlan_handle_dummy(struct net_device *, u16);
+static u32	tlan_handle_tx_eoc(struct net_device *, u16);
+static u32	tlan_handle_status_check(struct net_device *, u16);
+static u32	tlan_handle_rx_eoc(struct net_device *, u16);
+
+static void	tlan_timer(unsigned long);
+
+static void	tlan_reset_lists(struct net_device *);
+static void	tlan_free_lists(struct net_device *);
+static void	tlan_print_dio(u16);
+static void	tlan_print_list(struct tlan_list *, char *, int);
+static void	tlan_read_and_clear_stats(struct net_device *, int);
+static void	tlan_reset_adapter(struct net_device *);
+static void	tlan_finish_reset(struct net_device *);
+static void	tlan_set_mac(struct net_device *, int areg, char *mac);
+
+static void	tlan_phy_print(struct net_device *);
+static void	tlan_phy_detect(struct net_device *);
+static void	tlan_phy_power_down(struct net_device *);
+static void	tlan_phy_power_up(struct net_device *);
+static void	tlan_phy_reset(struct net_device *);
+static void	tlan_phy_start_link(struct net_device *);
+static void	tlan_phy_finish_auto_neg(struct net_device *);
 #ifdef MONITOR
-static void     TLan_PhyMonitor( struct net_device * );
+static void     tlan_phy_monitor(struct net_device *);
 #endif
 
 /*
-static int	TLan_PhyNop( struct net_device * );
-static int	TLan_PhyInternalCheck( struct net_device * );
-static int	TLan_PhyInternalService( struct net_device * );
-static int	TLan_PhyDp83840aCheck( struct net_device * );
+  static int	tlan_phy_nop(struct net_device *);
+  static int	tlan_phy_internal_check(struct net_device *);
+  static int	tlan_phy_internal_service(struct net_device *);
+  static int	tlan_phy_dp83840a_check(struct net_device *);
 */
 
-static bool	TLan_MiiReadReg( struct net_device *, u16, u16, u16 * );
-static void	TLan_MiiSendData( u16, u32, unsigned );
-static void	TLan_MiiSync( u16 );
-static void	TLan_MiiWriteReg( struct net_device *, u16, u16, u16 );
+static bool	tlan_mii_read_reg(struct net_device *, u16, u16, u16 *);
+static void	tlan_mii_send_data(u16, u32, unsigned);
+static void	tlan_mii_sync(u16);
+static void	tlan_mii_write_reg(struct net_device *, u16, u16, u16);
 
-static void	TLan_EeSendStart( u16 );
-static int	TLan_EeSendByte( u16, u8, int );
-static void	TLan_EeReceiveByte( u16, u8 *, int );
-static int	TLan_EeReadByte( struct net_device *, u8, u8 * );
+static void	tlan_ee_send_start(u16);
+static int	tlan_ee_send_byte(u16, u8, int);
+static void	tlan_ee_receive_byte(u16, u8 *, int);
+static int	tlan_ee_read_byte(struct net_device *, u8, u8 *);
 
 
 static inline void
-TLan_StoreSKB( struct tlan_list_tag *tag, struct sk_buff *skb)
+tlan_store_skb(struct tlan_list *tag, struct sk_buff *skb)
 {
 	unsigned long addr = (unsigned long)skb;
 	tag->buffer[9].address = addr;
@@ -358,7 +363,7 @@ TLan_StoreSKB( struct tlan_list_tag *tag, struct sk_buff *skb)
 }
 
 static inline struct sk_buff *
-TLan_GetSKB( const struct tlan_list_tag *tag)
+tlan_get_skb(const struct tlan_list *tag)
 {
 	unsigned long addr;
 
@@ -367,50 +372,50 @@ TLan_GetSKB( const struct tlan_list_tag *tag)
 	return (struct sk_buff *) addr;
 }
 
-
-static TLanIntVectorFunc *TLanIntVector[TLAN_INT_NUMBER_OF_INTS] = {
+static u32
+(*tlan_int_vector[TLAN_INT_NUMBER_OF_INTS])(struct net_device *, u16) = {
 	NULL,
-	TLan_HandleTxEOF,
-	TLan_HandleStatOverflow,
-	TLan_HandleRxEOF,
-	TLan_HandleDummy,
-	TLan_HandleTxEOC,
-	TLan_HandleStatusCheck,
-	TLan_HandleRxEOC
+	tlan_handle_tx_eof,
+	tlan_handle_stat_overflow,
+	tlan_handle_rx_eof,
+	tlan_handle_dummy,
+	tlan_handle_tx_eoc,
+	tlan_handle_status_check,
+	tlan_handle_rx_eoc
 };
 
 static inline void
-TLan_SetTimer( struct net_device *dev, u32 ticks, u32 type )
+tlan_set_timer(struct net_device *dev, u32 ticks, u32 type)
 {
-	TLanPrivateInfo *priv = netdev_priv(dev);
+	struct tlan_priv *priv = netdev_priv(dev);
 	unsigned long flags = 0;
 
 	if (!in_irq())
 		spin_lock_irqsave(&priv->lock, flags);
-	if ( priv->timer.function != NULL &&
-		priv->timerType != TLAN_TIMER_ACTIVITY ) {
+	if (priv->timer.function != NULL &&
+	    priv->timer_type != TLAN_TIMER_ACTIVITY) {
 		if (!in_irq())
 			spin_unlock_irqrestore(&priv->lock, flags);
 		return;
 	}
-	priv->timer.function = TLan_Timer;
+	priv->timer.function = tlan_timer;
 	if (!in_irq())
 		spin_unlock_irqrestore(&priv->lock, flags);
 
 	priv->timer.data = (unsigned long) dev;
-	priv->timerSetAt = jiffies;
-	priv->timerType = type;
+	priv->timer_set_at = jiffies;
+	priv->timer_type = type;
 	mod_timer(&priv->timer, jiffies + ticks);
 
-} /* TLan_SetTimer */
+}
 
 
 /*****************************************************************************
 ******************************************************************************
 
-	ThunderLAN Driver Primary Functions
+ThunderLAN driver primary functions
 
-	These functions are more or less common to all Linux network drivers.
+these functions are more or less common to all linux network drivers.
 
 ******************************************************************************
 *****************************************************************************/
@@ -419,42 +424,42 @@ TLan_SetTimer( struct net_device *dev, u32 ticks, u32 type )
 
 
 
-	/***************************************************************
-	 *	tlan_remove_one
-	 *
-	 *	Returns:
-	 *		Nothing
-	 *	Parms:
-	 *		None
-	 *
-	 *	Goes through the TLanDevices list and frees the device
-	 *	structs and memory associated with each device (lists
-	 *	and buffers).  It also ureserves the IO port regions
-	 *	associated with this device.
-	 *
-	 **************************************************************/
+/***************************************************************
+ *	tlan_remove_one
+ *
+ *	Returns:
+ *		Nothing
+ *	Parms:
+ *		None
+ *
+ *	Goes through the TLanDevices list and frees the device
+ *	structs and memory associated with each device (lists
+ *	and buffers).  It also ureserves the IO port regions
+ *	associated with this device.
+ *
+ **************************************************************/
 
 
-static void __devexit tlan_remove_one( struct pci_dev *pdev)
+static void __devexit tlan_remove_one(struct pci_dev *pdev)
 {
-	struct net_device *dev = pci_get_drvdata( pdev );
-	TLanPrivateInfo	*priv = netdev_priv(dev);
+	struct net_device *dev = pci_get_drvdata(pdev);
+	struct tlan_priv	*priv = netdev_priv(dev);
 
-	unregister_netdev( dev );
+	unregister_netdev(dev);
 
-	if ( priv->dmaStorage ) {
-		pci_free_consistent(priv->pciDev,
-				    priv->dmaSize, priv->dmaStorage,
-				    priv->dmaStorageDMA );
+	if (priv->dma_storage) {
+		pci_free_consistent(priv->pci_dev,
+				    priv->dma_size, priv->dma_storage,
+				    priv->dma_storage_dma);
 	}
 
 #ifdef CONFIG_PCI
 	pci_release_regions(pdev);
 #endif
 
-	free_netdev( dev );
+	free_netdev(dev);
 
-	pci_set_drvdata( pdev, NULL );
+	pci_set_drvdata(pdev, NULL);
 }
 
 static struct pci_driver tlan_driver = {
@@ -482,13 +487,13 @@ static int __init tlan_probe(void)
 	}
 
 	TLAN_DBG(TLAN_DEBUG_PROBE, "Starting EISA Probe....\n");
-	TLan_EisaProbe();
+	tlan_eisa_probe();
 
 	printk(KERN_INFO "TLAN: %d device%s installed, PCI: %d  EISA: %d\n",
-		 TLanDevicesInstalled, TLanDevicesInstalled == 1 ? "" : "s",
-		 tlan_have_pci, tlan_have_eisa);
+	       tlan_devices_installed, tlan_devices_installed == 1 ? "" : "s",
+	       tlan_have_pci, tlan_have_eisa);
 
-	if (TLanDevicesInstalled == 0) {
+	if (tlan_devices_installed == 0) {
 		rc = -ENODEV;
 		goto  err_out_pci_unreg;
 	}
@@ -501,39 +506,39 @@ err_out_pci_free:
 }
 
 
-static int __devinit tlan_init_one( struct pci_dev *pdev,
-				    const struct pci_device_id *ent)
+static int __devinit tlan_init_one(struct pci_dev *pdev,
+				   const struct pci_device_id *ent)
 {
-	return TLan_probe1( pdev, -1, -1, 0, ent);
+	return tlan_probe1(pdev, -1, -1, 0, ent);
 }
 
 
 /*
-	***************************************************************
-	 *	tlan_probe1
-	 *
-	 *	Returns:
-	 *		0 on success, error code on error
-	 *	Parms:
-	 *		none
-	 *
-	 *	The name is lower case to fit in with all the rest of
-	 *	the netcard_probe names.  This function looks for
-	 *	another TLan based adapter, setting it up with the
-	 *	allocated device struct if one is found.
-	 *	tlan_probe has been ported to the new net API and
-	 *	now allocates its own device structure. This function
-	 *	is also used by modules.
-	 *
-	 **************************************************************/
-
-static int __devinit TLan_probe1(struct pci_dev *pdev,
+***************************************************************
+*	tlan_probe1
+*
+*	Returns:
+*		0 on success, error code on error
+*	Parms:
+*		none
+*
+*	The name is lower case to fit in with all the rest of
+*	the netcard_probe names.  This function looks for
+*	another TLan based adapter, setting it up with the
+*	allocated device struct if one is found.
+*	tlan_probe has been ported to the new net API and
+*	now allocates its own device structure. This function
+*	is also used by modules.
+*
+**************************************************************/
+
+static int __devinit tlan_probe1(struct pci_dev *pdev,
 				 long ioaddr, int irq, int rev,
-				 const struct pci_device_id *ent )
+				 const struct pci_device_id *ent)
 {
 
 	struct net_device  *dev;
-	TLanPrivateInfo    *priv;
+	struct tlan_priv  *priv;
 	u16		   device_id;
 	int		   reg, rc = -ENODEV;
 
@@ -543,7 +548,7 @@ static int __devinit TLan_probe1(struct pci_dev *pdev,
 		if (rc)
 			return rc;
 
-		rc = pci_request_regions(pdev, TLanSignature);
+		rc = pci_request_regions(pdev, tlan_signature);
 		if (rc) {
 			printk(KERN_ERR "TLAN: Could not reserve IO regions\n");
 			goto err_out;
@@ -551,7 +556,7 @@ static int __devinit TLan_probe1(struct pci_dev *pdev,
 	}
 #endif  /*  CONFIG_PCI  */
 
-	dev = alloc_etherdev(sizeof(TLanPrivateInfo));
+	dev = alloc_etherdev(sizeof(struct tlan_priv));
 	if (dev == NULL) {
 		printk(KERN_ERR "TLAN: Could not allocate memory for device.\n");
 		rc = -ENOMEM;
@@ -561,26 +566,28 @@ static int __devinit TLan_probe1(struct pci_dev *pdev,
 
 	priv = netdev_priv(dev);
 
-	priv->pciDev = pdev;
+	priv->pci_dev = pdev;
 	priv->dev = dev;
 
 	/* Is this a PCI device? */
 	if (pdev) {
-		u32 		   pci_io_base = 0;
+		u32		   pci_io_base = 0;
 
 		priv->adapter = &board_info[ent->driver_data];
 
 		rc = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 		if (rc) {
-			printk(KERN_ERR "TLAN: No suitable PCI mapping available.\n");
+			printk(KERN_ERR
+			       "TLAN: No suitable PCI mapping available.\n");
 			goto err_out_free_dev;
 		}
 
-		for ( reg= 0; reg <= 5; reg ++ ) {
+		for (reg = 0; reg <= 5; reg++) {
 			if (pci_resource_flags(pdev, reg) & IORESOURCE_IO) {
 				pci_io_base = pci_resource_start(pdev, reg);
-				TLAN_DBG( TLAN_DEBUG_GNRL, "IO mapping is available at %x.\n",
-						pci_io_base);
+				TLAN_DBG(TLAN_DEBUG_GNRL,
+					 "IO mapping is available at %x.\n",
+					 pci_io_base);
 				break;
 			}
 		}
@@ -592,7 +599,7 @@ static int __devinit TLan_probe1(struct pci_dev *pdev,
 
 		dev->base_addr = pci_io_base;
 		dev->irq = pdev->irq;
-		priv->adapterRev = pdev->revision;
+		priv->adapter_rev = pdev->revision;
 		pci_set_master(pdev);
 		pci_set_drvdata(pdev, dev);
 
@@ -602,11 +609,11 @@ static int __devinit TLan_probe1(struct pci_dev *pdev,
 		device_id = inw(ioaddr + EISA_ID2);
 		priv->is_eisa = 1;
 		if (device_id == 0x20F1) {
-			priv->adapter = &board_info[13]; 	/* NetFlex-3/E */
-			priv->adapterRev = 23;			/* TLAN 2.3 */
+			priv->adapter = &board_info[13]; /* NetFlex-3/E */
+			priv->adapter_rev = 23;		/* TLAN 2.3 */
 		} else {
 			priv->adapter = &board_info[14];
-			priv->adapterRev = 10;			/* TLAN 1.0 */
+			priv->adapter_rev = 10;		/* TLAN 1.0 */
 		}
 		dev->base_addr = ioaddr;
 		dev->irq = irq;
@@ -620,11 +627,11 @@ static int __devinit TLan_probe1(struct pci_dev *pdev,
 		priv->speed  = ((dev->mem_start & 0x18) == 0x18) ? 0
 			: (dev->mem_start & 0x18) >> 3;
 
-		if (priv->speed == 0x1) {
+		if (priv->speed == 0x1)
 			priv->speed = TLAN_SPEED_10;
-		} else if (priv->speed == 0x2) {
+		else if (priv->speed == 0x2)
 			priv->speed = TLAN_SPEED_100;
-		}
+
 		debug = priv->debug = dev->mem_end;
 	} else {
 		priv->aui    = aui[boards_found];
@@ -635,11 +642,11 @@ static int __devinit TLan_probe1(struct pci_dev *pdev,
 
 	/* This will be used when we get an adapter error from
 	 * within our irq handler */
-	INIT_WORK(&priv->tlan_tqueue, TLan_tx_timeout_work);
+	INIT_WORK(&priv->tlan_tqueue, tlan_tx_timeout_work);
 
 	spin_lock_init(&priv->lock);
 
-	rc = TLan_Init(dev);
+	rc = tlan_init(dev);
 	if (rc) {
 		printk(KERN_ERR "TLAN: Could not set up device.\n");
 		goto err_out_free_dev;
@@ -652,29 +659,29 @@ static int __devinit TLan_probe1(struct pci_dev *pdev,
 	}
 
 
-	TLanDevicesInstalled++;
+	tlan_devices_installed++;
 	boards_found++;
 
 	/* pdev is NULL if this is an EISA device */
 	if (pdev)
 		tlan_have_pci++;
 	else {
-		priv->nextDevice = TLan_Eisa_Devices;
-		TLan_Eisa_Devices = dev;
+		priv->next_device = tlan_eisa_devices;
+		tlan_eisa_devices = dev;
 		tlan_have_eisa++;
 	}
 
 	printk(KERN_INFO "TLAN: %s irq=%2d, io=%04x, %s, Rev. %d\n",
-			dev->name,
-			(int) dev->irq,
-			(int) dev->base_addr,
-			priv->adapter->deviceLabel,
-			priv->adapterRev);
+	       dev->name,
+	       (int) dev->irq,
+	       (int) dev->base_addr,
+	       priv->adapter->device_label,
+	       priv->adapter_rev);
 	return 0;
 
 err_out_uninit:
-	pci_free_consistent(priv->pciDev, priv->dmaSize, priv->dmaStorage,
-			    priv->dmaStorageDMA );
+	pci_free_consistent(priv->pci_dev, priv->dma_size, priv->dma_storage,
+			    priv->dma_storage_dma);
 err_out_free_dev:
 	free_netdev(dev);
 err_out_regions:
@@ -689,22 +696,23 @@ err_out:
 }
 
 
-static void TLan_Eisa_Cleanup(void)
+static void tlan_eisa_cleanup(void)
 {
 	struct net_device *dev;
-	TLanPrivateInfo *priv;
+	struct tlan_priv *priv;
 
-	while( tlan_have_eisa ) {
-		dev = TLan_Eisa_Devices;
+	while (tlan_have_eisa) {
+		dev = tlan_eisa_devices;
 		priv = netdev_priv(dev);
-		if (priv->dmaStorage) {
-			pci_free_consistent(priv->pciDev, priv->dmaSize,
-					    priv->dmaStorage, priv->dmaStorageDMA );
+		if (priv->dma_storage) {
+			pci_free_consistent(priv->pci_dev, priv->dma_size,
+					    priv->dma_storage,
+					    priv->dma_storage_dma);
 		}
-		release_region( dev->base_addr, 0x10);
-		unregister_netdev( dev );
-		TLan_Eisa_Devices = priv->nextDevice;
-		free_netdev( dev );
+		release_region(dev->base_addr, 0x10);
+		unregister_netdev(dev);
+		tlan_eisa_devices = priv->next_device;
+		free_netdev(dev);
 		tlan_have_eisa--;
 	}
 }
@@ -715,7 +723,7 @@ static void __exit tlan_exit(void)
 	pci_unregister_driver(&tlan_driver);
 
 	if (tlan_have_eisa)
-		TLan_Eisa_Cleanup();
+		tlan_eisa_cleanup();
 
 }
 
@@ -726,24 +734,24 @@ module_exit(tlan_exit);
 
 
 
-	/**************************************************************
-	 * 	TLan_EisaProbe
-	 *
-	 *  	Returns: 0 on success, 1 otherwise
-	 *
-	 *  	Parms:	 None
-	 *
-	 *
-	 *  	This functions probes for EISA devices and calls
-	 *  	TLan_probe1 when one is found.
-	 *
-	 *************************************************************/
+/**************************************************************
+ *	tlan_eisa_probe
+ *
+ *	Returns: 0 on success, 1 otherwise
+ *
+ *	Parms:	 None
+ *
+ *
+ *	This functions probes for EISA devices and calls
+ *	TLan_probe1 when one is found.
+ *
+ *************************************************************/
 
-static void  __init TLan_EisaProbe (void)
+static void  __init tlan_eisa_probe(void)
 {
-	long 	ioaddr;
-	int 	rc = -ENODEV;
-	int 	irq;
+	long	ioaddr;
+	int	rc = -ENODEV;
+	int	irq;
 	u16	device_id;
 
 	if (!EISA_bus) {
@@ -754,15 +762,16 @@ static void  __init TLan_EisaProbe (void)
 	/* Loop through all slots of the EISA bus */
 	for (ioaddr = 0x1000; ioaddr < 0x9000; ioaddr += 0x1000) {
 
-	TLAN_DBG(TLAN_DEBUG_PROBE,"EISA_ID 0x%4x: 0x%4x\n",
-		 (int) ioaddr + 0xC80, inw(ioaddr + EISA_ID));
-	TLAN_DBG(TLAN_DEBUG_PROBE,"EISA_ID 0x%4x: 0x%4x\n",
-		 (int) ioaddr + 0xC82, inw(ioaddr + EISA_ID2));
+		TLAN_DBG(TLAN_DEBUG_PROBE, "EISA_ID 0x%4x: 0x%4x\n",
+			 (int) ioaddr + 0xc80, inw(ioaddr + EISA_ID));
+		TLAN_DBG(TLAN_DEBUG_PROBE, "EISA_ID 0x%4x: 0x%4x\n",
+			 (int) ioaddr + 0xc82, inw(ioaddr + EISA_ID2));
 
 
-		TLAN_DBG(TLAN_DEBUG_PROBE, "Probing for EISA adapter at IO: 0x%4x : ",
-				   	(int) ioaddr);
-		if (request_region(ioaddr, 0x10, TLanSignature) == NULL)
+		TLAN_DBG(TLAN_DEBUG_PROBE,
+			 "Probing for EISA adapter at IO: 0x%4x : ",
+			 (int) ioaddr);
+		if (request_region(ioaddr, 0x10, tlan_signature) == NULL)
 			goto out;
 
 		if (inw(ioaddr + EISA_ID) != 0x110E) {
@@ -772,180 +781,186 @@ static void  __init TLan_EisaProbe (void)
 
 		device_id = inw(ioaddr + EISA_ID2);
 		if (device_id !=  0x20F1 && device_id != 0x40F1) {
-			release_region (ioaddr, 0x10);
+			release_region(ioaddr, 0x10);
 			goto out;
 		}
 
-	 	if (inb(ioaddr + EISA_CR) != 0x1) { 	/* Check if adapter is enabled */
-			release_region (ioaddr, 0x10);
+		/* check if adapter is enabled */
+		if (inb(ioaddr + EISA_CR) != 0x1) {
+			release_region(ioaddr, 0x10);
 			goto out2;
 		}
 
 		if (debug == 0x10)
-			printk("Found one\n");
+			printk(KERN_INFO "Found one\n");
 
 
 		/* Get irq from board */
-		switch (inb(ioaddr + 0xCC0)) {
-			case(0x10):
-				irq=5;
-				break;
-			case(0x20):
-				irq=9;
-				break;
-			case(0x40):
-				irq=10;
-				break;
-			case(0x80):
-				irq=11;
-				break;
-			default:
-				goto out;
+		switch (inb(ioaddr + 0xcc0)) {
+		case(0x10):
+			irq = 5;
+			break;
+		case(0x20):
+			irq = 9;
+			break;
+		case(0x40):
+			irq = 10;
+			break;
+		case(0x80):
+			irq = 11;
+			break;
+		default:
+			goto out;
 		}
 
 
 		/* Setup the newly found eisa adapter */
-		rc = TLan_probe1( NULL, ioaddr, irq,
-					12, NULL);
+		rc = tlan_probe1(NULL, ioaddr, irq,
+				 12, NULL);
 		continue;
 
-		out:
-			if (debug == 0x10)
-				printk("None found\n");
-			continue;
+out:
+		if (debug == 0x10)
+			printk(KERN_INFO "None found\n");
+		continue;
 
-		out2:	if (debug == 0x10)
-				printk("Card found but it is not enabled, skipping\n");
-			continue;
+out2:
+		if (debug == 0x10)
+			printk(KERN_INFO "Card found but it is not enabled, skipping\n");
+		continue;
 
 	}
 
-} /* TLan_EisaProbe */
+}
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
-static void TLan_Poll(struct net_device *dev)
+static void tlan_poll(struct net_device *dev)
 {
 	disable_irq(dev->irq);
-	TLan_HandleInterrupt(dev->irq, dev);
+	tlan_handle_interrupt(dev->irq, dev);
 	enable_irq(dev->irq);
 }
 #endif
 
-static const struct net_device_ops TLan_netdev_ops = {
-	.ndo_open 		= TLan_Open,
-	.ndo_stop		= TLan_Close,
-	.ndo_start_xmit		= TLan_StartTx,
-	.ndo_tx_timeout		= TLan_tx_timeout,
-	.ndo_get_stats		= TLan_GetStats,
-	.ndo_set_multicast_list = TLan_SetMulticastList,
-	.ndo_do_ioctl		= TLan_ioctl,
+static const struct net_device_ops tlan_netdev_ops = {
+	.ndo_open		= tlan_open,
+	.ndo_stop		= tlan_close,
+	.ndo_start_xmit		= tlan_start_tx,
+	.ndo_tx_timeout		= tlan_tx_timeout,
+	.ndo_get_stats		= tlan_get_stats,
+	.ndo_set_multicast_list = tlan_set_multicast_list,
+	.ndo_do_ioctl		= tlan_ioctl,
 	.ndo_change_mtu		= eth_change_mtu,
-	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_set_mac_address	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
 #ifdef CONFIG_NET_POLL_CONTROLLER
-	.ndo_poll_controller	 = TLan_Poll,
+	.ndo_poll_controller	 = tlan_poll,
 #endif
 };
 
 
 
-	/***************************************************************
-	 *	TLan_Init
-	 *
-	 *	Returns:
-	 *		0 on success, error code otherwise.
-	 *	Parms:
-	 *		dev	The structure of the device to be
-	 *			init'ed.
-	 *
-	 *	This function completes the initialization of the
-	 *	device structure and driver.  It reserves the IO
-	 *	addresses, allocates memory for the lists and bounce
-	 *	buffers, retrieves the MAC address from the eeprom
-	 *	and assignes the device's methods.
-	 *
-	 **************************************************************/
-
-static int TLan_Init( struct net_device *dev )
+/***************************************************************
+ *	tlan_init
+ *
+ *	Returns:
+ *		0 on success, error code otherwise.
+ *	Parms:
+ *		dev	The structure of the device to be
+ *			init'ed.
+ *
+ *	This function completes the initialization of the
+ *	device structure and driver.  It reserves the IO
+ *	addresses, allocates memory for the lists and bounce
+ *	buffers, retrieves the MAC address from the eeprom
+ *	and assignes the device's methods.
+ *
+ **************************************************************/
+
+static int tlan_init(struct net_device *dev)
 {
 	int		dma_size;
-	int 		err;
+	int		err;
 	int		i;
-	TLanPrivateInfo	*priv;
+	struct tlan_priv	*priv;
 
 	priv = netdev_priv(dev);
 
-	dma_size = ( TLAN_NUM_RX_LISTS + TLAN_NUM_TX_LISTS )
-		* ( sizeof(TLanList) );
-	priv->dmaStorage = pci_alloc_consistent(priv->pciDev,
-						dma_size, &priv->dmaStorageDMA);
-	priv->dmaSize = dma_size;
-
-	if ( priv->dmaStorage == NULL ) {
-		printk(KERN_ERR "TLAN:  Could not allocate lists and buffers for %s.\n",
-			dev->name );
+	dma_size = (TLAN_NUM_RX_LISTS + TLAN_NUM_TX_LISTS)
+		* (sizeof(struct tlan_list));
+	priv->dma_storage = pci_alloc_consistent(priv->pci_dev,
+						 dma_size,
+						 &priv->dma_storage_dma);
+	priv->dma_size = dma_size;
+
+	if (priv->dma_storage == NULL) {
+		printk(KERN_ERR
+		       "TLAN:  Could not allocate lists and buffers for %s.\n",
+		       dev->name);
 		return -ENOMEM;
 	}
-	memset( priv->dmaStorage, 0, dma_size );
-	priv->rxList = (TLanList *) ALIGN((unsigned long)priv->dmaStorage, 8);
-	priv->rxListDMA = ALIGN(priv->dmaStorageDMA, 8);
-	priv->txList = priv->rxList + TLAN_NUM_RX_LISTS;
-	priv->txListDMA = priv->rxListDMA + sizeof(TLanList) * TLAN_NUM_RX_LISTS;
+	memset(priv->dma_storage, 0, dma_size);
+	priv->rx_list = (struct tlan_list *)
+		ALIGN((unsigned long)priv->dma_storage, 8);
+	priv->rx_list_dma = ALIGN(priv->dma_storage_dma, 8);
+	priv->tx_list = priv->rx_list + TLAN_NUM_RX_LISTS;
+	priv->tx_list_dma =
+		priv->rx_list_dma + sizeof(struct tlan_list)*TLAN_NUM_RX_LISTS;
 
 	err = 0;
-	for ( i = 0;  i < 6 ; i++ )
-		err |= TLan_EeReadByte( dev,
-					(u8) priv->adapter->addrOfs + i,
-					(u8 *) &dev->dev_addr[i] );
-	if ( err ) {
+	for (i = 0;  i < 6 ; i++)
+		err |= tlan_ee_read_byte(dev,
+					 (u8) priv->adapter->addr_ofs + i,
+					 (u8 *) &dev->dev_addr[i]);
+	if (err) {
 		printk(KERN_ERR "TLAN: %s: Error reading MAC from eeprom: %d\n",
-			dev->name,
-			err );
+		       dev->name,
+		       err);
 	}
 	dev->addr_len = 6;
 
 	netif_carrier_off(dev);
 
 	/* Device methods */
-	dev->netdev_ops = &TLan_netdev_ops;
+	dev->netdev_ops = &tlan_netdev_ops;
 	dev->watchdog_timeo = TX_TIMEOUT;
 
 	return 0;
 
-} /* TLan_Init */
+}
 
 
 
 
-	/***************************************************************
-	 *	TLan_Open
-	 *
-	 *	Returns:
-	 *		0 on success, error code otherwise.
-	 *	Parms:
-	 *		dev	Structure of device to be opened.
-	 *
-	 *	This routine puts the driver and TLAN adapter in a
-	 *	state where it is ready to send and receive packets.
-	 *	It allocates the IRQ, resets and brings the adapter
-	 *	out of reset, and allows interrupts.  It also delays
-	 *	the startup for autonegotiation or sends a Rx GO
-	 *	command to the adapter, as appropriate.
-	 *
-	 **************************************************************/
+/***************************************************************
+ *	tlan_open
+ *
+ *	Returns:
+ *		0 on success, error code otherwise.
+ *	Parms:
+ *		dev	Structure of device to be opened.
+ *
+ *	This routine puts the driver and TLAN adapter in a
+ *	state where it is ready to send and receive packets.
+ *	It allocates the IRQ, resets and brings the adapter
+ *	out of reset, and allows interrupts.  It also delays
+ *	the startup for autonegotiation or sends a Rx GO
+ *	command to the adapter, as appropriate.
+ *
+ **************************************************************/
 
-static int TLan_Open( struct net_device *dev )
+static int tlan_open(struct net_device *dev)
 {
-	TLanPrivateInfo	*priv = netdev_priv(dev);
+	struct tlan_priv	*priv = netdev_priv(dev);
 	int		err;
 
-	priv->tlanRev = TLan_DioRead8( dev->base_addr, TLAN_DEF_REVISION );
-	err = request_irq( dev->irq, TLan_HandleInterrupt, IRQF_SHARED,
-			   dev->name, dev );
+	priv->tlan_rev = tlan_dio_read8(dev->base_addr, TLAN_DEF_REVISION);
+	err = request_irq(dev->irq, tlan_handle_interrupt, IRQF_SHARED,
+			  dev->name, dev);
 
-	if ( err ) {
+	if (err) {
 		pr_err("TLAN:  Cannot open %s because IRQ %d is already in use.\n",
-		       dev->name, dev->irq );
+		       dev->name, dev->irq);
 		return err;
 	}
 
@@ -953,145 +968,145 @@ static int TLan_Open( struct net_device *dev )
 	netif_start_queue(dev);
 
 	/* NOTE: It might not be necessary to read the stats before a
-			 reset if you don't care what the values are.
+	   reset if you don't care what the values are.
 	*/
-	TLan_ResetLists( dev );
-	TLan_ReadAndClearStats( dev, TLAN_IGNORE );
-	TLan_ResetAdapter( dev );
+	tlan_reset_lists(dev);
+	tlan_read_and_clear_stats(dev, TLAN_IGNORE);
+	tlan_reset_adapter(dev);
 
-	TLAN_DBG( TLAN_DEBUG_GNRL, "%s: Opened.  TLAN Chip Rev: %x\n",
-		  dev->name, priv->tlanRev );
+	TLAN_DBG(TLAN_DEBUG_GNRL, "%s: Opened.  TLAN Chip Rev: %x\n",
+		 dev->name, priv->tlan_rev);
 
 	return 0;
 
-} /* TLan_Open */
+}
 
 
 
-	/**************************************************************
-	 *	TLan_ioctl
-	 *
-	 *	Returns:
-	 *		0 on success, error code otherwise
-	 *	Params:
-	 *		dev	structure of device to receive ioctl.
-	 *
-	 *		rq	ifreq structure to hold userspace data.
-	 *
-	 *		cmd	ioctl command.
-	 *
-	 *
-	 *************************************************************/
+/**************************************************************
+ *	tlan_ioctl
+ *
+ *	Returns:
+ *		0 on success, error code otherwise
+ *	Params:
+ *		dev	structure of device to receive ioctl.
+ *
+ *		rq	ifreq structure to hold userspace data.
+ *
+ *		cmd	ioctl command.
+ *
+ *
+ *************************************************************/
 
-static int TLan_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
+static int tlan_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
-	TLanPrivateInfo *priv = netdev_priv(dev);
+	struct tlan_priv *priv = netdev_priv(dev);
 	struct mii_ioctl_data *data = if_mii(rq);
-	u32 phy   = priv->phy[priv->phyNum];
+	u32 phy   = priv->phy[priv->phy_num];
 
-	if (!priv->phyOnline)
+	if (!priv->phy_online)
 		return -EAGAIN;
 
-	switch(cmd) {
-	case SIOCGMIIPHY:		/* Get address of MII PHY in use. */
-			data->phy_id = phy;
+	switch (cmd) {
+	case SIOCGMIIPHY:		/* get address of MII PHY in use. */
+		data->phy_id = phy;
 
 
-	case SIOCGMIIREG:		/* Read MII PHY register. */
-			TLan_MiiReadReg(dev, data->phy_id & 0x1f,
-					data->reg_num & 0x1f, &data->val_out);
-			return 0;
+	case SIOCGMIIREG:		/* read MII PHY register. */
+		tlan_mii_read_reg(dev, data->phy_id & 0x1f,
+				  data->reg_num & 0x1f, &data->val_out);
+		return 0;
 
 
-	case SIOCSMIIREG:		/* Write MII PHY register. */
-			TLan_MiiWriteReg(dev, data->phy_id & 0x1f,
-					 data->reg_num & 0x1f, data->val_in);
-			return 0;
-		default:
-			return -EOPNOTSUPP;
+	case SIOCSMIIREG:		/* write MII PHY register. */
+		tlan_mii_write_reg(dev, data->phy_id & 0x1f,
+				   data->reg_num & 0x1f, data->val_in);
+		return 0;
+	default:
+		return -EOPNOTSUPP;
 	}
-} /* tlan_ioctl */
+}
 
 
-	/***************************************************************
-	 * 	TLan_tx_timeout
-	 *
-	 * 	Returns: nothing
-	 *
-	 * 	Params:
-	 * 		dev	structure of device which timed out
-	 * 			during transmit.
-	 *
-	 **************************************************************/
+/***************************************************************
+ *	tlan_tx_timeout
+ *
+ *	Returns: nothing
+ *
+ *	Params:
+ *		dev	structure of device which timed out
+ *			during transmit.
+ *
+ **************************************************************/
 
-static void TLan_tx_timeout(struct net_device *dev)
+static void tlan_tx_timeout(struct net_device *dev)
 {
 
-	TLAN_DBG( TLAN_DEBUG_GNRL, "%s: Transmit timed out.\n", dev->name);
+	TLAN_DBG(TLAN_DEBUG_GNRL, "%s: Transmit timed out.\n", dev->name);
 
 	/* Ok so we timed out, lets see what we can do about it...*/
-	TLan_FreeLists( dev );
-	TLan_ResetLists( dev );
-	TLan_ReadAndClearStats( dev, TLAN_IGNORE );
-	TLan_ResetAdapter( dev );
+	tlan_free_lists(dev);
+	tlan_reset_lists(dev);
+	tlan_read_and_clear_stats(dev, TLAN_IGNORE);
+	tlan_reset_adapter(dev);
 	dev->trans_start = jiffies; /* prevent tx timeout */
-	netif_wake_queue( dev );
+	netif_wake_queue(dev);
 
 }
 
 
-	/***************************************************************
-	 * 	TLan_tx_timeout_work
-	 *
-	 * 	Returns: nothing
-	 *
-	 * 	Params:
-	 * 		work	work item of device which timed out
-	 *
-	 **************************************************************/
+/***************************************************************
+ *	tlan_tx_timeout_work
+ *
+ *	Returns: nothing
+ *
+ *	Params:
+ *		work	work item of device which timed out
+ *
+ **************************************************************/
 
-static void TLan_tx_timeout_work(struct work_struct *work)
+static void tlan_tx_timeout_work(struct work_struct *work)
 {
-	TLanPrivateInfo	*priv =
-		container_of(work, TLanPrivateInfo, tlan_tqueue);
+	struct tlan_priv	*priv =
+		container_of(work, struct tlan_priv, tlan_tqueue);
 
-	TLan_tx_timeout(priv->dev);
+	tlan_tx_timeout(priv->dev);
 }
 
 
 
-	/***************************************************************
-	 *	TLan_StartTx
-	 *
-	 *	Returns:
-	 *		0 on success, non-zero on failure.
-	 *	Parms:
-	 *		skb	A pointer to the sk_buff containing the
-	 *			frame to be sent.
-	 *		dev	The device to send the data on.
-	 *
-	 *	This function adds a frame to the Tx list to be sent
-	 *	ASAP.  First it	verifies that the adapter is ready and
-	 *	there is room in the queue.  Then it sets up the next
-	 *	available list, copies the frame to the	corresponding
-	 *	buffer.  If the adapter Tx channel is idle, it gives
-	 *	the adapter a Tx Go command on the list, otherwise it
-	 *	sets the forward address of the previous list to point
-	 *	to this one.  Then it frees the sk_buff.
-	 *
-	 **************************************************************/
-
-static netdev_tx_t TLan_StartTx( struct sk_buff *skb, struct net_device *dev )
+/***************************************************************
+ *	tlan_start_tx
+ *
+ *	Returns:
+ *		0 on success, non-zero on failure.
+ *	Parms:
+ *		skb	A pointer to the sk_buff containing the
+ *			frame to be sent.
+ *		dev	The device to send the data on.
+ *
+ *	This function adds a frame to the Tx list to be sent
+ *	ASAP.  First it	verifies that the adapter is ready and
+ *	there is room in the queue.  Then it sets up the next
+ *	available list, copies the frame to the	corresponding
+ *	buffer.  If the adapter Tx channel is idle, it gives
+ *	the adapter a Tx Go command on the list, otherwise it
+ *	sets the forward address of the previous list to point
+ *	to this one.  Then it frees the sk_buff.
+ *
+ **************************************************************/
+
+static netdev_tx_t tlan_start_tx(struct sk_buff *skb, struct net_device *dev)
 {
-	TLanPrivateInfo *priv = netdev_priv(dev);
+	struct tlan_priv *priv = netdev_priv(dev);
 	dma_addr_t	tail_list_phys;
-	TLanList	*tail_list;
+	struct tlan_list	*tail_list;
 	unsigned long	flags;
 	unsigned int    txlen;
 
-	if ( ! priv->phyOnline ) {
-		TLAN_DBG( TLAN_DEBUG_TX, "TRANSMIT:  %s PHY is not ready\n",
-			  dev->name );
+	if (!priv->phy_online) {
+		TLAN_DBG(TLAN_DEBUG_TX, "TRANSMIT:  %s PHY is not ready\n",
+			 dev->name);
 		dev_kfree_skb_any(skb);
 		return NETDEV_TX_OK;
 	}
@@ -1100,218 +1115,221 @@ static netdev_tx_t TLan_StartTx( struct sk_buff *skb, struct net_device *dev )
 		return NETDEV_TX_OK;
 	txlen = max(skb->len, (unsigned int)TLAN_MIN_FRAME_SIZE);
 
-	tail_list = priv->txList + priv->txTail;
-	tail_list_phys = priv->txListDMA + sizeof(TLanList) * priv->txTail;
+	tail_list = priv->tx_list + priv->tx_tail;
+	tail_list_phys =
+		priv->tx_list_dma + sizeof(struct tlan_list)*priv->tx_tail;
 
-	if ( tail_list->cStat != TLAN_CSTAT_UNUSED ) {
-		TLAN_DBG( TLAN_DEBUG_TX,
-			  "TRANSMIT:  %s is busy (Head=%d Tail=%d)\n",
-			  dev->name, priv->txHead, priv->txTail );
+	if (tail_list->c_stat != TLAN_CSTAT_UNUSED) {
+		TLAN_DBG(TLAN_DEBUG_TX,
+			 "TRANSMIT:  %s is busy (Head=%d Tail=%d)\n",
+			 dev->name, priv->tx_head, priv->tx_tail);
 		netif_stop_queue(dev);
-		priv->txBusyCount++;
+		priv->tx_busy_count++;
 		return NETDEV_TX_BUSY;
 	}
 
 	tail_list->forward = 0;
 
-	tail_list->buffer[0].address = pci_map_single(priv->pciDev,
+	tail_list->buffer[0].address = pci_map_single(priv->pci_dev,
 						      skb->data, txlen,
 						      PCI_DMA_TODEVICE);
-	TLan_StoreSKB(tail_list, skb);
+	tlan_store_skb(tail_list, skb);
 
-	tail_list->frameSize = (u16) txlen;
+	tail_list->frame_size = (u16) txlen;
 	tail_list->buffer[0].count = TLAN_LAST_BUFFER | (u32) txlen;
 	tail_list->buffer[1].count = 0;
 	tail_list->buffer[1].address = 0;
 
 	spin_lock_irqsave(&priv->lock, flags);
-	tail_list->cStat = TLAN_CSTAT_READY;
-	if ( ! priv->txInProgress ) {
-		priv->txInProgress = 1;
-		TLAN_DBG( TLAN_DEBUG_TX,
-			  "TRANSMIT:  Starting TX on buffer %d\n", priv->txTail );
-		outl( tail_list_phys, dev->base_addr + TLAN_CH_PARM );
-		outl( TLAN_HC_GO, dev->base_addr + TLAN_HOST_CMD );
+	tail_list->c_stat = TLAN_CSTAT_READY;
+	if (!priv->tx_in_progress) {
+		priv->tx_in_progress = 1;
+		TLAN_DBG(TLAN_DEBUG_TX,
+			 "TRANSMIT:  Starting TX on buffer %d\n",
+			 priv->tx_tail);
+		outl(tail_list_phys, dev->base_addr + TLAN_CH_PARM);
+		outl(TLAN_HC_GO, dev->base_addr + TLAN_HOST_CMD);
 	} else {
-		TLAN_DBG( TLAN_DEBUG_TX, "TRANSMIT:  Adding buffer %d to TX channel\n",
-			  priv->txTail );
-		if ( priv->txTail == 0 ) {
-			( priv->txList + ( TLAN_NUM_TX_LISTS - 1 ) )->forward
+		TLAN_DBG(TLAN_DEBUG_TX,
+			 "TRANSMIT:  Adding buffer %d to TX channel\n",
+			 priv->tx_tail);
+		if (priv->tx_tail == 0) {
+			(priv->tx_list + (TLAN_NUM_TX_LISTS - 1))->forward
 				= tail_list_phys;
 		} else {
-			( priv->txList + ( priv->txTail - 1 ) )->forward
+			(priv->tx_list + (priv->tx_tail - 1))->forward
 				= tail_list_phys;
 		}
 	}
 	spin_unlock_irqrestore(&priv->lock, flags);
 
-	CIRC_INC( priv->txTail, TLAN_NUM_TX_LISTS );
+	CIRC_INC(priv->tx_tail, TLAN_NUM_TX_LISTS);
 
 	return NETDEV_TX_OK;
 
-} /* TLan_StartTx */
+}
 
 
 
 
-	/***************************************************************
-	 *	TLan_HandleInterrupt
-	 *
-	 *	Returns:
-	 *		Nothing
-	 *	Parms:
-	 *		irq	The line on which the interrupt
-	 *			occurred.
-	 *		dev_id	A pointer to the device assigned to
-	 *			this irq line.
-	 *
-	 *	This function handles an interrupt generated by its
-	 *	assigned TLAN adapter.  The function deactivates
-	 *	interrupts on its adapter, records the type of
-	 *	interrupt, executes the appropriate subhandler, and
-	 *	acknowdges the interrupt to the adapter (thus
-	 *	re-enabling adapter interrupts.
-	 *
-	 **************************************************************/
+/***************************************************************
+ *	tlan_handle_interrupt
+ *
+ *	Returns:
+ *		Nothing
+ *	Parms:
+ *		irq	The line on which the interrupt
+ *			occurred.
+ *		dev_id	A pointer to the device assigned to
+ *			this irq line.
+ *
+ *	This function handles an interrupt generated by its
+ *	assigned TLAN adapter.  The function deactivates
+ *	interrupts on its adapter, records the type of
+ *	interrupt, executes the appropriate subhandler, and
+ *	acknowdges the interrupt to the adapter (thus
+ *	re-enabling adapter interrupts.
+ *
+ **************************************************************/
 
-static irqreturn_t TLan_HandleInterrupt(int irq, void *dev_id)
+static irqreturn_t tlan_handle_interrupt(int irq, void *dev_id)
 {
 	struct net_device	*dev = dev_id;
-	TLanPrivateInfo *priv = netdev_priv(dev);
+	struct tlan_priv *priv = netdev_priv(dev);
 	u16		host_int;
 	u16		type;
 
 	spin_lock(&priv->lock);
 
-	host_int = inw( dev->base_addr + TLAN_HOST_INT );
-	type = ( host_int & TLAN_HI_IT_MASK ) >> 2;
-	if ( type ) {
+	host_int = inw(dev->base_addr + TLAN_HOST_INT);
+	type = (host_int & TLAN_HI_IT_MASK) >> 2;
+	if (type) {
 		u32	ack;
 		u32	host_cmd;
 
-		outw( host_int, dev->base_addr + TLAN_HOST_INT );
-		ack = TLanIntVector[type]( dev, host_int );
+		outw(host_int, dev->base_addr + TLAN_HOST_INT);
+		ack = tlan_int_vector[type](dev, host_int);
 
-		if ( ack ) {
-			host_cmd = TLAN_HC_ACK | ack | ( type << 18 );
-			outl( host_cmd, dev->base_addr + TLAN_HOST_CMD );
+		if (ack) {
+			host_cmd = TLAN_HC_ACK | ack | (type << 18);
+			outl(host_cmd, dev->base_addr + TLAN_HOST_CMD);
 		}
 	}
 
 	spin_unlock(&priv->lock);
 
 	return IRQ_RETVAL(type);
-} /* TLan_HandleInterrupts */
+}
 
 
 
 
-	/***************************************************************
-	 *	TLan_Close
-	 *
-	 * 	Returns:
-	 *		An error code.
-	 *	Parms:
-	 *		dev	The device structure of the device to
-	 *			close.
-	 *
-	 *	This function shuts down the adapter.  It records any
-	 *	stats, puts the adapter into reset state, deactivates
-	 *	its time as needed, and	frees the irq it is using.
-	 *
-	 **************************************************************/
+/***************************************************************
+ *	tlan_close
+ *
+ *	Returns:
+ *		An error code.
+ *	Parms:
+ *		dev	The device structure of the device to
+ *			close.
+ *
+ *	This function shuts down the adapter.  It records any
+ *	stats, puts the adapter into reset state, deactivates
+ *	its time as needed, and	frees the irq it is using.
+ *
+ **************************************************************/
 
-static int TLan_Close(struct net_device *dev)
+static int tlan_close(struct net_device *dev)
 {
-	TLanPrivateInfo *priv = netdev_priv(dev);
+	struct tlan_priv *priv = netdev_priv(dev);
 
 	netif_stop_queue(dev);
 	priv->neg_be_verbose = 0;
 
-	TLan_ReadAndClearStats( dev, TLAN_RECORD );
-	outl( TLAN_HC_AD_RST, dev->base_addr + TLAN_HOST_CMD );
-	if ( priv->timer.function != NULL ) {
-		del_timer_sync( &priv->timer );
+	tlan_read_and_clear_stats(dev, TLAN_RECORD);
+	outl(TLAN_HC_AD_RST, dev->base_addr + TLAN_HOST_CMD);
+	if (priv->timer.function != NULL) {
+		del_timer_sync(&priv->timer);
 		priv->timer.function = NULL;
 	}
 
-	free_irq( dev->irq, dev );
-	TLan_FreeLists( dev );
-	TLAN_DBG( TLAN_DEBUG_GNRL, "Device %s closed.\n", dev->name );
+	free_irq(dev->irq, dev);
+	tlan_free_lists(dev);
+	TLAN_DBG(TLAN_DEBUG_GNRL, "Device %s closed.\n", dev->name);
 
 	return 0;
 
-} /* TLan_Close */
+}
 
 
 
 
-	/***************************************************************
-	 *	TLan_GetStats
-	 *
-	 *	Returns:
-	 *		A pointer to the device's statistics structure.
-	 *	Parms:
-	 *		dev	The device structure to return the
-	 *			stats for.
-	 *
-	 *	This function updates the devices statistics by reading
-	 *	the TLAN chip's onboard registers.  Then it returns the
-	 *	address of the statistics structure.
-	 *
-	 **************************************************************/
+/***************************************************************
+ *	tlan_get_stats
+ *
+ *	Returns:
+ *		A pointer to the device's statistics structure.
+ *	Parms:
+ *		dev	The device structure to return the
+ *			stats for.
+ *
+ *	This function updates the devices statistics by reading
+ *	the TLAN chip's onboard registers.  Then it returns the
+ *	address of the statistics structure.
+ *
+ **************************************************************/
 
-static struct net_device_stats *TLan_GetStats( struct net_device *dev )
+static struct net_device_stats *tlan_get_stats(struct net_device *dev)
 {
-	TLanPrivateInfo	*priv = netdev_priv(dev);
+	struct tlan_priv	*priv = netdev_priv(dev);
 	int i;
 
 	/* Should only read stats if open ? */
-	TLan_ReadAndClearStats( dev, TLAN_RECORD );
+	tlan_read_and_clear_stats(dev, TLAN_RECORD);
 
-	TLAN_DBG( TLAN_DEBUG_RX, "RECEIVE:  %s EOC count = %d\n", dev->name,
-		  priv->rxEocCount );
-	TLAN_DBG( TLAN_DEBUG_TX, "TRANSMIT:  %s Busy count = %d\n", dev->name,
-		  priv->txBusyCount );
-	if ( debug & TLAN_DEBUG_GNRL ) {
-		TLan_PrintDio( dev->base_addr );
-		TLan_PhyPrint( dev );
+	TLAN_DBG(TLAN_DEBUG_RX, "RECEIVE:  %s EOC count = %d\n", dev->name,
+		 priv->rx_eoc_count);
+	TLAN_DBG(TLAN_DEBUG_TX, "TRANSMIT:  %s Busy count = %d\n", dev->name,
+		 priv->tx_busy_count);
+	if (debug & TLAN_DEBUG_GNRL) {
+		tlan_print_dio(dev->base_addr);
+		tlan_phy_print(dev);
 	}
-	if ( debug & TLAN_DEBUG_LIST ) {
-		for ( i = 0; i < TLAN_NUM_RX_LISTS; i++ )
-			TLan_PrintList( priv->rxList + i, "RX", i );
-		for ( i = 0; i < TLAN_NUM_TX_LISTS; i++ )
-			TLan_PrintList( priv->txList + i, "TX", i );
+	if (debug & TLAN_DEBUG_LIST) {
+		for (i = 0; i < TLAN_NUM_RX_LISTS; i++)
+			tlan_print_list(priv->rx_list + i, "RX", i);
+		for (i = 0; i < TLAN_NUM_TX_LISTS; i++)
+			tlan_print_list(priv->tx_list + i, "TX", i);
 	}
 
 	return &dev->stats;
 
-} /* TLan_GetStats */
+}
 
 
 
 
-	/***************************************************************
-	 *	TLan_SetMulticastList
-	 *
-	 *	Returns:
-	 *		Nothing
-	 *	Parms:
-	 *		dev	The device structure to set the
-	 *			multicast list for.
-	 *
-	 *	This function sets the TLAN adaptor to various receive
-	 *	modes.  If the IFF_PROMISC flag is set, promiscuous
-	 *	mode is acitviated.  Otherwise,	promiscuous mode is
-	 *	turned off.  If the IFF_ALLMULTI flag is set, then
-	 *	the hash table is set to receive all group addresses.
-	 *	Otherwise, the first three multicast addresses are
-	 *	stored in AREG_1-3, and the rest are selected via the
-	 *	hash table, as necessary.
-	 *
-	 **************************************************************/
+/***************************************************************
+ *	tlan_set_multicast_list
+ *
+ *	Returns:
+ *		Nothing
+ *	Parms:
+ *		dev	The device structure to set the
+ *			multicast list for.
+ *
+ *	This function sets the TLAN adaptor to various receive
+ *	modes.  If the IFF_PROMISC flag is set, promiscuous
+ *	mode is acitviated.  Otherwise,	promiscuous mode is
+ *	turned off.  If the IFF_ALLMULTI flag is set, then
+ *	the hash table is set to receive all group addresses.
+ *	Otherwise, the first three multicast addresses are
+ *	stored in AREG_1-3, and the rest are selected via the
+ *	hash table, as necessary.
+ *
+ **************************************************************/
 
-static void TLan_SetMulticastList( struct net_device *dev )
+static void tlan_set_multicast_list(struct net_device *dev)
 {
 	struct netdev_hw_addr *ha;
 	u32			hash1 = 0;
@@ -1320,53 +1338,56 @@ static void TLan_SetMulticastList( struct net_device *dev )
 	u32			offset;
 	u8			tmp;
 
-	if ( dev->flags & IFF_PROMISC ) {
-		tmp = TLan_DioRead8( dev->base_addr, TLAN_NET_CMD );
-		TLan_DioWrite8( dev->base_addr,
-				TLAN_NET_CMD, tmp | TLAN_NET_CMD_CAF );
+	if (dev->flags & IFF_PROMISC) {
+		tmp = tlan_dio_read8(dev->base_addr, TLAN_NET_CMD);
+		tlan_dio_write8(dev->base_addr,
+				TLAN_NET_CMD, tmp | TLAN_NET_CMD_CAF);
 	} else {
-		tmp = TLan_DioRead8( dev->base_addr, TLAN_NET_CMD );
-		TLan_DioWrite8( dev->base_addr,
-				TLAN_NET_CMD, tmp & ~TLAN_NET_CMD_CAF );
-		if ( dev->flags & IFF_ALLMULTI ) {
-			for ( i = 0; i < 3; i++ )
-				TLan_SetMac( dev, i + 1, NULL );
-			TLan_DioWrite32( dev->base_addr, TLAN_HASH_1, 0xFFFFFFFF );
-			TLan_DioWrite32( dev->base_addr, TLAN_HASH_2, 0xFFFFFFFF );
+		tmp = tlan_dio_read8(dev->base_addr, TLAN_NET_CMD);
+		tlan_dio_write8(dev->base_addr,
+				TLAN_NET_CMD, tmp & ~TLAN_NET_CMD_CAF);
+		if (dev->flags & IFF_ALLMULTI) {
+			for (i = 0; i < 3; i++)
+				tlan_set_mac(dev, i + 1, NULL);
+			tlan_dio_write32(dev->base_addr, TLAN_HASH_1,
+					 0xffffffff);
+			tlan_dio_write32(dev->base_addr, TLAN_HASH_2,
+					 0xffffffff);
 		} else {
 			i = 0;
 			netdev_for_each_mc_addr(ha, dev) {
-				if ( i < 3 ) {
-					TLan_SetMac( dev, i + 1,
+				if (i < 3) {
+					tlan_set_mac(dev, i + 1,
 						     (char *) &ha->addr);
 				} else {
-					offset = TLan_HashFunc((u8 *)&ha->addr);
-					if ( offset < 32 )
-						hash1 |= ( 1 << offset );
+					offset =
+						tlan_hash_func((u8 *)&ha->addr);
+					if (offset < 32)
+						hash1 |= (1 << offset);
 					else
-						hash2 |= ( 1 << ( offset - 32 ) );
+						hash2 |= (1 << (offset - 32));
 				}
 				i++;
 			}
-			for ( ; i < 3; i++ )
-				TLan_SetMac( dev, i + 1, NULL );
-			TLan_DioWrite32( dev->base_addr, TLAN_HASH_1, hash1 );
-			TLan_DioWrite32( dev->base_addr, TLAN_HASH_2, hash2 );
+			for ( ; i < 3; i++)
+				tlan_set_mac(dev, i + 1, NULL);
+			tlan_dio_write32(dev->base_addr, TLAN_HASH_1, hash1);
+			tlan_dio_write32(dev->base_addr, TLAN_HASH_2, hash2);
 		}
 	}
 
-} /* TLan_SetMulticastList */
+}
 
 
 
 /*****************************************************************************
 ******************************************************************************
 
-        ThunderLAN Driver Interrupt Vectors and Table
+ThunderLAN driver interrupt vectors and table
 
-	Please see Chap. 4, "Interrupt Handling" of the "ThunderLAN
-	Programmer's Guide" for more informations on handling interrupts
-	generated by TLAN based adapters.
+please see chap. 4, "Interrupt Handling" of the "ThunderLAN
+Programmer's Guide" for more informations on handling interrupts
+generated by TLAN based adapters.
 
 ******************************************************************************
 *****************************************************************************/
@@ -1374,46 +1395,48 @@ static void TLan_SetMulticastList( struct net_device *dev )
 
 
 
-	/***************************************************************
-	 *	TLan_HandleTxEOF
-	 *
-	 *	Returns:
-	 *		1
-	 *	Parms:
-	 *		dev		Device assigned the IRQ that was
-	 *				raised.
-	 *		host_int	The contents of the HOST_INT
-	 *				port.
-	 *
-	 *	This function handles Tx EOF interrupts which are raised
-	 *	by the adapter when it has completed sending the
-	 *	contents of a buffer.  If detemines which list/buffer
-	 *	was completed and resets it.  If the buffer was the last
-	 *	in the channel (EOC), then the function checks to see if
-	 *	another buffer is ready to send, and if so, sends a Tx
-	 *	Go command.  Finally, the driver activates/continues the
-	 *	activity LED.
-	 *
-	 **************************************************************/
-
-static u32 TLan_HandleTxEOF( struct net_device *dev, u16 host_int )
+/***************************************************************
+ *	tlan_handle_tx_eof
+ *
+ *	Returns:
+ *		1
+ *	Parms:
+ *		dev		Device assigned the IRQ that was
+ *				raised.
+ *		host_int	The contents of the HOST_INT
+ *				port.
+ *
+ *	This function handles Tx EOF interrupts which are raised
+ *	by the adapter when it has completed sending the
+ *	contents of a buffer.  If detemines which list/buffer
+ *	was completed and resets it.  If the buffer was the last
+ *	in the channel (EOC), then the function checks to see if
+ *	another buffer is ready to send, and if so, sends a Tx
+ *	Go command.  Finally, the driver activates/continues the
+ *	activity LED.
+ *
+ **************************************************************/
+
+static u32 tlan_handle_tx_eof(struct net_device *dev, u16 host_int)
 {
-	TLanPrivateInfo	*priv = netdev_priv(dev);
+	struct tlan_priv	*priv = netdev_priv(dev);
 	int		eoc = 0;
-	TLanList	*head_list;
+	struct tlan_list	*head_list;
 	dma_addr_t	head_list_phys;
 	u32		ack = 0;
-	u16		tmpCStat;
+	u16		tmp_c_stat;
 
-	TLAN_DBG( TLAN_DEBUG_TX, "TRANSMIT:  Handling TX EOF (Head=%d Tail=%d)\n",
-		  priv->txHead, priv->txTail );
-	head_list = priv->txList + priv->txHead;
+	TLAN_DBG(TLAN_DEBUG_TX,
+		 "TRANSMIT:  Handling TX EOF (Head=%d Tail=%d)\n",
+		 priv->tx_head, priv->tx_tail);
+	head_list = priv->tx_list + priv->tx_head;
 
-	while (((tmpCStat = head_list->cStat ) & TLAN_CSTAT_FRM_CMP) && (ack < 255)) {
-		struct sk_buff *skb = TLan_GetSKB(head_list);
+	while (((tmp_c_stat = head_list->c_stat) & TLAN_CSTAT_FRM_CMP)
+	       && (ack < 255)) {
+		struct sk_buff *skb = tlan_get_skb(head_list);
 
 		ack++;
-		pci_unmap_single(priv->pciDev, head_list->buffer[0].address,
+		pci_unmap_single(priv->pci_dev, head_list->buffer[0].address,
 				 max(skb->len,
 				     (unsigned int)TLAN_MIN_FRAME_SIZE),
 				 PCI_DMA_TODEVICE);
@@ -1421,304 +1444,311 @@ static u32 TLan_HandleTxEOF( struct net_device *dev, u16 host_int )
 		head_list->buffer[8].address = 0;
 		head_list->buffer[9].address = 0;
 
-		if ( tmpCStat & TLAN_CSTAT_EOC )
+		if (tmp_c_stat & TLAN_CSTAT_EOC)
 			eoc = 1;
 
-		dev->stats.tx_bytes += head_list->frameSize;
+		dev->stats.tx_bytes += head_list->frame_size;
 
-		head_list->cStat = TLAN_CSTAT_UNUSED;
+		head_list->c_stat = TLAN_CSTAT_UNUSED;
 		netif_start_queue(dev);
-		CIRC_INC( priv->txHead, TLAN_NUM_TX_LISTS );
-		head_list = priv->txList + priv->txHead;
+		CIRC_INC(priv->tx_head, TLAN_NUM_TX_LISTS);
+		head_list = priv->tx_list + priv->tx_head;
 	}
 
 	if (!ack)
-		printk(KERN_INFO "TLAN: Received interrupt for uncompleted TX frame.\n");
-
-	if ( eoc ) {
-		TLAN_DBG( TLAN_DEBUG_TX,
-			  "TRANSMIT:  Handling TX EOC (Head=%d Tail=%d)\n",
-			  priv->txHead, priv->txTail );
-		head_list = priv->txList + priv->txHead;
-		head_list_phys = priv->txListDMA + sizeof(TLanList) * priv->txHead;
-		if ( ( head_list->cStat & TLAN_CSTAT_READY ) == TLAN_CSTAT_READY ) {
-			outl(head_list_phys, dev->base_addr + TLAN_CH_PARM );
+		printk(KERN_INFO
+		       "TLAN: Received interrupt for uncompleted TX frame.\n");
+
+	if (eoc) {
+		TLAN_DBG(TLAN_DEBUG_TX,
+			 "TRANSMIT:  handling TX EOC (Head=%d Tail=%d)\n",
+			 priv->tx_head, priv->tx_tail);
+		head_list = priv->tx_list + priv->tx_head;
+		head_list_phys = priv->tx_list_dma
+			+ sizeof(struct tlan_list)*priv->tx_head;
+		if (head_list->c_stat & TLAN_CSTAT_READY) {
+			outl(head_list_phys, dev->base_addr + TLAN_CH_PARM);
 			ack |= TLAN_HC_GO;
 		} else {
-			priv->txInProgress = 0;
+			priv->tx_in_progress = 0;
 		}
 	}
 
-	if ( priv->adapter->flags & TLAN_ADAPTER_ACTIVITY_LED ) {
-		TLan_DioWrite8( dev->base_addr,
-				TLAN_LED_REG, TLAN_LED_LINK | TLAN_LED_ACT );
-		if ( priv->timer.function == NULL ) {
-			 priv->timer.function = TLan_Timer;
-			 priv->timer.data = (unsigned long) dev;
-			 priv->timer.expires = jiffies + TLAN_TIMER_ACT_DELAY;
-			 priv->timerSetAt = jiffies;
-			 priv->timerType = TLAN_TIMER_ACTIVITY;
-			 add_timer(&priv->timer);
-		} else if ( priv->timerType == TLAN_TIMER_ACTIVITY ) {
-			priv->timerSetAt = jiffies;
+	if (priv->adapter->flags & TLAN_ADAPTER_ACTIVITY_LED) {
+		tlan_dio_write8(dev->base_addr,
+				TLAN_LED_REG, TLAN_LED_LINK | TLAN_LED_ACT);
+		if (priv->timer.function == NULL) {
+			priv->timer.function = tlan_timer;
+			priv->timer.data = (unsigned long) dev;
+			priv->timer.expires = jiffies + TLAN_TIMER_ACT_DELAY;
+			priv->timer_set_at = jiffies;
+			priv->timer_type = TLAN_TIMER_ACTIVITY;
+			add_timer(&priv->timer);
+		} else if (priv->timer_type == TLAN_TIMER_ACTIVITY) {
+			priv->timer_set_at = jiffies;
 		}
 	}
 
 	return ack;
 
-} /* TLan_HandleTxEOF */
+}
 
 
 
 
-	/***************************************************************
-	 *	TLan_HandleStatOverflow
-	 *
-	 *	Returns:
-	 *		1
-	 *	Parms:
-	 *		dev		Device assigned the IRQ that was
-	 *				raised.
-	 *		host_int	The contents of the HOST_INT
-	 *				port.
-	 *
-	 *	This function handles the Statistics Overflow interrupt
-	 *	which means that one or more of the TLAN statistics
-	 *	registers has reached 1/2 capacity and needs to be read.
-	 *
-	 **************************************************************/
+/***************************************************************
+ *	TLan_HandleStatOverflow
+ *
+ *	Returns:
+ *		1
+ *	Parms:
+ *		dev		Device assigned the IRQ that was
+ *				raised.
+ *		host_int	The contents of the HOST_INT
+ *				port.
+ *
+ *	This function handles the Statistics Overflow interrupt
+ *	which means that one or more of the TLAN statistics
+ *	registers has reached 1/2 capacity and needs to be read.
+ *
+ **************************************************************/
 
-static u32 TLan_HandleStatOverflow( struct net_device *dev, u16 host_int )
+static u32 tlan_handle_stat_overflow(struct net_device *dev, u16 host_int)
 {
-	TLan_ReadAndClearStats( dev, TLAN_RECORD );
+	tlan_read_and_clear_stats(dev, TLAN_RECORD);
 
 	return 1;
 
-} /* TLan_HandleStatOverflow */
-
-
-
-
-	/***************************************************************
-	 *	TLan_HandleRxEOF
-	 *
-	 *	Returns:
-	 *		1
-	 *	Parms:
-	 *		dev		Device assigned the IRQ that was
-	 *				raised.
-	 *		host_int	The contents of the HOST_INT
-	 *				port.
-	 *
-	 *	This function handles the Rx EOF interrupt which
-	 *	indicates a frame has been received by the adapter from
-	 *	the net and the frame has been transferred to memory.
-	 *	The function determines the bounce buffer the frame has
-	 *	been loaded into, creates a new sk_buff big enough to
-	 *	hold the frame, and sends it to protocol stack.  It
-	 *	then resets the used buffer and appends it to the end
-	 *	of the list.  If the frame was the last in the Rx
-	 *	channel (EOC), the function restarts the receive channel
-	 *	by sending an Rx Go command to the adapter.  Then it
-	 *	activates/continues the activity LED.
-	 *
-	 **************************************************************/
-
-static u32 TLan_HandleRxEOF( struct net_device *dev, u16 host_int )
+}
+
+
+
+
+/***************************************************************
+ *	TLan_HandleRxEOF
+ *
+ *	Returns:
+ *		1
+ *	Parms:
+ *		dev		Device assigned the IRQ that was
+ *				raised.
+ *		host_int	The contents of the HOST_INT
+ *				port.
+ *
+ *	This function handles the Rx EOF interrupt which
+ *	indicates a frame has been received by the adapter from
+ *	the net and the frame has been transferred to memory.
+ *	The function determines the bounce buffer the frame has
+ *	been loaded into, creates a new sk_buff big enough to
+ *	hold the frame, and sends it to protocol stack.  It
+ *	then resets the used buffer and appends it to the end
+ *	of the list.  If the frame was the last in the Rx
+ *	channel (EOC), the function restarts the receive channel
+ *	by sending an Rx Go command to the adapter.  Then it
+ *	activates/continues the activity LED.
+ *
+ **************************************************************/
+
+static u32 tlan_handle_rx_eof(struct net_device *dev, u16 host_int)
 {
-	TLanPrivateInfo	*priv = netdev_priv(dev);
+	struct tlan_priv	*priv = netdev_priv(dev);
 	u32		ack = 0;
 	int		eoc = 0;
-	TLanList	*head_list;
+	struct tlan_list	*head_list;
 	struct sk_buff	*skb;
-	TLanList	*tail_list;
-	u16		tmpCStat;
+	struct tlan_list	*tail_list;
+	u16		tmp_c_stat;
 	dma_addr_t	head_list_phys;
 
-	TLAN_DBG( TLAN_DEBUG_RX, "RECEIVE:  Handling RX EOF (Head=%d Tail=%d)\n",
-		  priv->rxHead, priv->rxTail );
-	head_list = priv->rxList + priv->rxHead;
-	head_list_phys = priv->rxListDMA + sizeof(TLanList) * priv->rxHead;
+	TLAN_DBG(TLAN_DEBUG_RX, "RECEIVE:  handling RX EOF (Head=%d Tail=%d)\n",
+		 priv->rx_head, priv->rx_tail);
+	head_list = priv->rx_list + priv->rx_head;
+	head_list_phys =
+		priv->rx_list_dma + sizeof(struct tlan_list)*priv->rx_head;
 
-	while (((tmpCStat = head_list->cStat) & TLAN_CSTAT_FRM_CMP) && (ack < 255)) {
-		dma_addr_t frameDma = head_list->buffer[0].address;
-		u32 frameSize = head_list->frameSize;
+	while (((tmp_c_stat = head_list->c_stat) & TLAN_CSTAT_FRM_CMP)
+	       && (ack < 255)) {
+		dma_addr_t frame_dma = head_list->buffer[0].address;
+		u32 frame_size = head_list->frame_size;
 		struct sk_buff *new_skb;
 
 		ack++;
-		if (tmpCStat & TLAN_CSTAT_EOC)
+		if (tmp_c_stat & TLAN_CSTAT_EOC)
 			eoc = 1;
 
 		new_skb = netdev_alloc_skb_ip_align(dev,
 						    TLAN_MAX_FRAME_SIZE + 5);
-		if ( !new_skb )
+		if (!new_skb)
 			goto drop_and_reuse;
 
-		skb = TLan_GetSKB(head_list);
-		pci_unmap_single(priv->pciDev, frameDma,
+		skb = tlan_get_skb(head_list);
+		pci_unmap_single(priv->pci_dev, frame_dma,
 				 TLAN_MAX_FRAME_SIZE, PCI_DMA_FROMDEVICE);
-		skb_put( skb, frameSize );
+		skb_put(skb, frame_size);
 
-		dev->stats.rx_bytes += frameSize;
+		dev->stats.rx_bytes += frame_size;
 
-		skb->protocol = eth_type_trans( skb, dev );
-		netif_rx( skb );
+		skb->protocol = eth_type_trans(skb, dev);
+		netif_rx(skb);
 
-		head_list->buffer[0].address = pci_map_single(priv->pciDev,
-							      new_skb->data,
-							      TLAN_MAX_FRAME_SIZE,
-							      PCI_DMA_FROMDEVICE);
+		head_list->buffer[0].address =
+			pci_map_single(priv->pci_dev, new_skb->data,
+				       TLAN_MAX_FRAME_SIZE, PCI_DMA_FROMDEVICE);
 
-		TLan_StoreSKB(head_list, new_skb);
+		tlan_store_skb(head_list, new_skb);
 drop_and_reuse:
 		head_list->forward = 0;
-		head_list->cStat = 0;
-		tail_list = priv->rxList + priv->rxTail;
+		head_list->c_stat = 0;
+		tail_list = priv->rx_list + priv->rx_tail;
 		tail_list->forward = head_list_phys;
 
-		CIRC_INC( priv->rxHead, TLAN_NUM_RX_LISTS );
-		CIRC_INC( priv->rxTail, TLAN_NUM_RX_LISTS );
-		head_list = priv->rxList + priv->rxHead;
-		head_list_phys = priv->rxListDMA + sizeof(TLanList) * priv->rxHead;
+		CIRC_INC(priv->rx_head, TLAN_NUM_RX_LISTS);
+		CIRC_INC(priv->rx_tail, TLAN_NUM_RX_LISTS);
+		head_list = priv->rx_list + priv->rx_head;
+		head_list_phys = priv->rx_list_dma
+			+ sizeof(struct tlan_list)*priv->rx_head;
 	}
 
 	if (!ack)
-		printk(KERN_INFO "TLAN: Received interrupt for uncompleted RX frame.\n");
-
-
-	if ( eoc ) {
-		TLAN_DBG( TLAN_DEBUG_RX,
-			  "RECEIVE:  Handling RX EOC (Head=%d Tail=%d)\n",
-			  priv->rxHead, priv->rxTail );
-		head_list = priv->rxList + priv->rxHead;
-		head_list_phys = priv->rxListDMA + sizeof(TLanList) * priv->rxHead;
-		outl(head_list_phys, dev->base_addr + TLAN_CH_PARM );
+		printk(KERN_INFO
+		       "TLAN: Received interrupt for uncompleted RX frame.\n");
+
+
+	if (eoc) {
+		TLAN_DBG(TLAN_DEBUG_RX,
+			 "RECEIVE:  handling RX EOC (Head=%d Tail=%d)\n",
+			 priv->rx_head, priv->rx_tail);
+		head_list = priv->rx_list + priv->rx_head;
+		head_list_phys = priv->rx_list_dma
+			+ sizeof(struct tlan_list)*priv->rx_head;
+		outl(head_list_phys, dev->base_addr + TLAN_CH_PARM);
 		ack |= TLAN_HC_GO | TLAN_HC_RT;
-		priv->rxEocCount++;
+		priv->rx_eoc_count++;
 	}
 
-	if ( priv->adapter->flags & TLAN_ADAPTER_ACTIVITY_LED ) {
-		TLan_DioWrite8( dev->base_addr,
-				TLAN_LED_REG, TLAN_LED_LINK | TLAN_LED_ACT );
-		if ( priv->timer.function == NULL )  {
-			priv->timer.function = TLan_Timer;
+	if (priv->adapter->flags & TLAN_ADAPTER_ACTIVITY_LED) {
+		tlan_dio_write8(dev->base_addr,
+				TLAN_LED_REG, TLAN_LED_LINK | TLAN_LED_ACT);
+		if (priv->timer.function == NULL)  {
+			priv->timer.function = tlan_timer;
 			priv->timer.data = (unsigned long) dev;
 			priv->timer.expires = jiffies + TLAN_TIMER_ACT_DELAY;
-			priv->timerSetAt = jiffies;
-			priv->timerType = TLAN_TIMER_ACTIVITY;
+			priv->timer_set_at = jiffies;
+			priv->timer_type = TLAN_TIMER_ACTIVITY;
 			add_timer(&priv->timer);
-		} else if ( priv->timerType == TLAN_TIMER_ACTIVITY ) {
-			priv->timerSetAt = jiffies;
+		} else if (priv->timer_type == TLAN_TIMER_ACTIVITY) {
+			priv->timer_set_at = jiffies;
 		}
 	}
 
 	return ack;
 
-} /* TLan_HandleRxEOF */
+}
 
 
 
 
-	/***************************************************************
-	 *	TLan_HandleDummy
-	 *
-	 *	Returns:
-	 *		1
-	 *	Parms:
-	 *		dev		Device assigned the IRQ that was
-	 *				raised.
-	 *		host_int	The contents of the HOST_INT
-	 *				port.
-	 *
-	 *	This function handles the Dummy interrupt, which is
-	 *	raised whenever a test interrupt is generated by setting
-	 *	the Req_Int bit of HOST_CMD to 1.
-	 *
-	 **************************************************************/
+/***************************************************************
+ *	tlan_handle_dummy
+ *
+ *	Returns:
+ *		1
+ *	Parms:
+ *		dev		Device assigned the IRQ that was
+ *				raised.
+ *		host_int	The contents of the HOST_INT
+ *				port.
+ *
+ *	This function handles the Dummy interrupt, which is
+ *	raised whenever a test interrupt is generated by setting
+ *	the Req_Int bit of HOST_CMD to 1.
+ *
+ **************************************************************/
 
-static u32 TLan_HandleDummy( struct net_device *dev, u16 host_int )
+static u32 tlan_handle_dummy(struct net_device *dev, u16 host_int)
 {
-	printk( "TLAN:  Test interrupt on %s.\n", dev->name );
+	pr_info("TLAN:  Test interrupt on %s.\n", dev->name);
 	return 1;
 
-} /* TLan_HandleDummy */
+}
 
 
 
 
-	/***************************************************************
-	 *	TLan_HandleTxEOC
-	 *
-	 *	Returns:
-	 *		1
-	 *	Parms:
-	 *		dev		Device assigned the IRQ that was
-	 *				raised.
-	 *		host_int	The contents of the HOST_INT
-	 *				port.
-	 *
-	 *	This driver is structured to determine EOC occurrences by
-	 *	reading the CSTAT member of the list structure.  Tx EOC
-	 *	interrupts are disabled via the DIO INTDIS register.
-	 *	However, TLAN chips before revision 3.0 didn't have this
-	 *	functionality, so process EOC events if this is the
-	 *	case.
-	 *
-	 **************************************************************/
+/***************************************************************
+ *	tlan_handle_tx_eoc
+ *
+ *	Returns:
+ *		1
+ *	Parms:
+ *		dev		Device assigned the IRQ that was
+ *				raised.
+ *		host_int	The contents of the HOST_INT
+ *				port.
+ *
+ *	This driver is structured to determine EOC occurrences by
+ *	reading the CSTAT member of the list structure.  Tx EOC
+ *	interrupts are disabled via the DIO INTDIS register.
+ *	However, TLAN chips before revision 3.0 didn't have this
+ *	functionality, so process EOC events if this is the
+ *	case.
+ *
+ **************************************************************/
 
-static u32 TLan_HandleTxEOC( struct net_device *dev, u16 host_int )
+static u32 tlan_handle_tx_eoc(struct net_device *dev, u16 host_int)
 {
-	TLanPrivateInfo	*priv = netdev_priv(dev);
-	TLanList		*head_list;
+	struct tlan_priv	*priv = netdev_priv(dev);
+	struct tlan_list		*head_list;
 	dma_addr_t		head_list_phys;
 	u32			ack = 1;
 
 	host_int = 0;
-	if ( priv->tlanRev < 0x30 ) {
-		TLAN_DBG( TLAN_DEBUG_TX,
-			  "TRANSMIT:  Handling TX EOC (Head=%d Tail=%d) -- IRQ\n",
-			  priv->txHead, priv->txTail );
-		head_list = priv->txList + priv->txHead;
-		head_list_phys = priv->txListDMA + sizeof(TLanList) * priv->txHead;
-		if ( ( head_list->cStat & TLAN_CSTAT_READY ) == TLAN_CSTAT_READY ) {
+	if (priv->tlan_rev < 0x30) {
+		TLAN_DBG(TLAN_DEBUG_TX,
+			 "TRANSMIT:  handling TX EOC (Head=%d Tail=%d) -- IRQ\n",
+			 priv->tx_head, priv->tx_tail);
+		head_list = priv->tx_list + priv->tx_head;
+		head_list_phys = priv->tx_list_dma
+			+ sizeof(struct tlan_list)*priv->tx_head;
+		if (head_list->c_stat & TLAN_CSTAT_READY) {
 			netif_stop_queue(dev);
-			outl( head_list_phys, dev->base_addr + TLAN_CH_PARM );
+			outl(head_list_phys, dev->base_addr + TLAN_CH_PARM);
 			ack |= TLAN_HC_GO;
 		} else {
-			priv->txInProgress = 0;
+			priv->tx_in_progress = 0;
 		}
 	}
 
 	return ack;
 
-} /* TLan_HandleTxEOC */
+}
 
 
 
 
-	/***************************************************************
-	 *	TLan_HandleStatusCheck
-	 *
-	 *	Returns:
-	 *		0 if Adapter check, 1 if Network Status check.
-	 *	Parms:
-	 *		dev		Device assigned the IRQ that was
-	 *				raised.
-	 *		host_int	The contents of the HOST_INT
-	 *				port.
-	 *
-	 *	This function handles Adapter Check/Network Status
-	 *	interrupts generated by the adapter.  It checks the
-	 *	vector in the HOST_INT register to determine if it is
-	 *	an Adapter Check interrupt.  If so, it resets the
-	 *	adapter.  Otherwise it clears the status registers
-	 *	and services the PHY.
-	 *
-	 **************************************************************/
+/***************************************************************
+ *	tlan_handle_status_check
+ *
+ *	Returns:
+ *		0 if Adapter check, 1 if Network Status check.
+ *	Parms:
+ *		dev		Device assigned the IRQ that was
+ *				raised.
+ *		host_int	The contents of the HOST_INT
+ *				port.
+ *
+ *	This function handles Adapter Check/Network Status
+ *	interrupts generated by the adapter.  It checks the
+ *	vector in the HOST_INT register to determine if it is
+ *	an Adapter Check interrupt.  If so, it resets the
+ *	adapter.  Otherwise it clears the status registers
+ *	and services the PHY.
+ *
+ **************************************************************/
 
-static u32 TLan_HandleStatusCheck( struct net_device *dev, u16 host_int )
+static u32 tlan_handle_status_check(struct net_device *dev, u16 host_int)
 {
-	TLanPrivateInfo	*priv = netdev_priv(dev);
+	struct tlan_priv	*priv = netdev_priv(dev);
 	u32		ack;
 	u32		error;
 	u8		net_sts;
@@ -1727,92 +1757,94 @@ static u32 TLan_HandleStatusCheck( struct net_device *dev, u16 host_int )
 	u16		tlphy_sts;
 
 	ack = 1;
-	if ( host_int & TLAN_HI_IV_MASK ) {
-		netif_stop_queue( dev );
-		error = inl( dev->base_addr + TLAN_CH_PARM );
-		printk( "TLAN:  %s: Adaptor Error = 0x%x\n", dev->name, error );
-		TLan_ReadAndClearStats( dev, TLAN_RECORD );
-		outl( TLAN_HC_AD_RST, dev->base_addr + TLAN_HOST_CMD );
+	if (host_int & TLAN_HI_IV_MASK) {
+		netif_stop_queue(dev);
+		error = inl(dev->base_addr + TLAN_CH_PARM);
+		pr_info("TLAN:  %s: Adaptor Error = 0x%x\n", dev->name, error);
+		tlan_read_and_clear_stats(dev, TLAN_RECORD);
+		outl(TLAN_HC_AD_RST, dev->base_addr + TLAN_HOST_CMD);
 
 		schedule_work(&priv->tlan_tqueue);
 
 		netif_wake_queue(dev);
 		ack = 0;
 	} else {
-		TLAN_DBG( TLAN_DEBUG_GNRL, "%s: Status Check\n", dev->name );
-		phy = priv->phy[priv->phyNum];
-
-		net_sts = TLan_DioRead8( dev->base_addr, TLAN_NET_STS );
-		if ( net_sts ) {
-			TLan_DioWrite8( dev->base_addr, TLAN_NET_STS, net_sts );
-			TLAN_DBG( TLAN_DEBUG_GNRL, "%s:    Net_Sts = %x\n",
-				  dev->name, (unsigned) net_sts );
+		TLAN_DBG(TLAN_DEBUG_GNRL, "%s: Status Check\n", dev->name);
+		phy = priv->phy[priv->phy_num];
+
+		net_sts = tlan_dio_read8(dev->base_addr, TLAN_NET_STS);
+		if (net_sts) {
+			tlan_dio_write8(dev->base_addr, TLAN_NET_STS, net_sts);
+			TLAN_DBG(TLAN_DEBUG_GNRL, "%s:    Net_Sts = %x\n",
+				 dev->name, (unsigned) net_sts);
 		}
-		if ( ( net_sts & TLAN_NET_STS_MIRQ ) &&  ( priv->phyNum == 0 ) ) {
-			TLan_MiiReadReg( dev, phy, TLAN_TLPHY_STS, &tlphy_sts );
-			TLan_MiiReadReg( dev, phy, TLAN_TLPHY_CTL, &tlphy_ctl );
-        		if ( ! ( tlphy_sts & TLAN_TS_POLOK ) &&
-			     ! ( tlphy_ctl & TLAN_TC_SWAPOL ) ) {
-                		tlphy_ctl |= TLAN_TC_SWAPOL;
-                		TLan_MiiWriteReg( dev, phy, TLAN_TLPHY_CTL, tlphy_ctl);
-			} else if ( ( tlphy_sts & TLAN_TS_POLOK ) &&
-				    ( tlphy_ctl & TLAN_TC_SWAPOL ) ) {
-                		tlphy_ctl &= ~TLAN_TC_SWAPOL;
-                		TLan_MiiWriteReg( dev, phy, TLAN_TLPHY_CTL, tlphy_ctl);
-        		}
-
-			if (debug) {
-				TLan_PhyPrint( dev );
+		if ((net_sts & TLAN_NET_STS_MIRQ) &&  (priv->phy_num == 0)) {
+			tlan_mii_read_reg(dev, phy, TLAN_TLPHY_STS, &tlphy_sts);
+			tlan_mii_read_reg(dev, phy, TLAN_TLPHY_CTL, &tlphy_ctl);
+			if (!(tlphy_sts & TLAN_TS_POLOK) &&
+			    !(tlphy_ctl & TLAN_TC_SWAPOL)) {
+				tlphy_ctl |= TLAN_TC_SWAPOL;
+				tlan_mii_write_reg(dev, phy, TLAN_TLPHY_CTL,
+						   tlphy_ctl);
+			} else if ((tlphy_sts & TLAN_TS_POLOK) &&
+				   (tlphy_ctl & TLAN_TC_SWAPOL)) {
+				tlphy_ctl &= ~TLAN_TC_SWAPOL;
+				tlan_mii_write_reg(dev, phy, TLAN_TLPHY_CTL,
+						   tlphy_ctl);
 			}
+
+			if (debug)
+				tlan_phy_print(dev);
 		}
 	}
 
 	return ack;
 
-} /* TLan_HandleStatusCheck */
+}
 
 
 
 
-	/***************************************************************
-	 *	TLan_HandleRxEOC
-	 *
-	 *	Returns:
-	 *		1
-	 *	Parms:
-	 *		dev		Device assigned the IRQ that was
-	 *				raised.
-	 *		host_int	The contents of the HOST_INT
-	 *				port.
-	 *
-	 *	This driver is structured to determine EOC occurrences by
-	 *	reading the CSTAT member of the list structure.  Rx EOC
-	 *	interrupts are disabled via the DIO INTDIS register.
-	 *	However, TLAN chips before revision 3.0 didn't have this
-	 *	CSTAT member or a INTDIS register, so if this chip is
-	 *	pre-3.0, process EOC interrupts normally.
-	 *
-	 **************************************************************/
+/***************************************************************
+ *	tlan_handle_rx_eoc
+ *
+ *	Returns:
+ *		1
+ *	Parms:
+ *		dev		Device assigned the IRQ that was
+ *				raised.
+ *		host_int	The contents of the HOST_INT
+ *				port.
+ *
+ *	This driver is structured to determine EOC occurrences by
+ *	reading the CSTAT member of the list structure.  Rx EOC
+ *	interrupts are disabled via the DIO INTDIS register.
+ *	However, TLAN chips before revision 3.0 didn't have this
+ *	CSTAT member or a INTDIS register, so if this chip is
+ *	pre-3.0, process EOC interrupts normally.
+ *
+ **************************************************************/
 
-static u32 TLan_HandleRxEOC( struct net_device *dev, u16 host_int )
+static u32 tlan_handle_rx_eoc(struct net_device *dev, u16 host_int)
 {
-	TLanPrivateInfo	*priv = netdev_priv(dev);
+	struct tlan_priv	*priv = netdev_priv(dev);
 	dma_addr_t	head_list_phys;
 	u32		ack = 1;
 
-	if (  priv->tlanRev < 0x30 ) {
-		TLAN_DBG( TLAN_DEBUG_RX,
-			  "RECEIVE:  Handling RX EOC (Head=%d Tail=%d) -- IRQ\n",
-			  priv->rxHead, priv->rxTail );
-		head_list_phys = priv->rxListDMA + sizeof(TLanList) * priv->rxHead;
-		outl( head_list_phys, dev->base_addr + TLAN_CH_PARM );
+	if (priv->tlan_rev < 0x30) {
+		TLAN_DBG(TLAN_DEBUG_RX,
+			 "RECEIVE:  Handling RX EOC (head=%d tail=%d) -- IRQ\n",
+			 priv->rx_head, priv->rx_tail);
+		head_list_phys = priv->rx_list_dma
+			+ sizeof(struct tlan_list)*priv->rx_head;
+		outl(head_list_phys, dev->base_addr + TLAN_CH_PARM);
 		ack |= TLAN_HC_GO | TLAN_HC_RT;
-		priv->rxEocCount++;
+		priv->rx_eoc_count++;
 	}
 
 	return ack;
 
-} /* TLan_HandleRxEOC */
+}
 
 
 
@@ -1820,98 +1852,98 @@ static u32 TLan_HandleRxEOC( struct net_device *dev, u16 host_int )
 /*****************************************************************************
 ******************************************************************************
 
-	ThunderLAN Driver Timer Function
+ThunderLAN driver timer function
 
 ******************************************************************************
 *****************************************************************************/
 
 
-	/***************************************************************
-	 *	TLan_Timer
-	 *
-	 *	Returns:
-	 *		Nothing
-	 *	Parms:
-	 *		data	A value given to add timer when
-	 *			add_timer was called.
-	 *
-	 *	This function handles timed functionality for the
-	 *	TLAN driver.  The two current timer uses are for
-	 *	delaying for autonegotionation and driving the ACT LED.
-	 *	-	Autonegotiation requires being allowed about
-	 *		2 1/2 seconds before attempting to transmit a
-	 *		packet.  It would be a very bad thing to hang
-	 *		the kernel this long, so the driver doesn't
-	 *		allow transmission 'til after this time, for
-	 *		certain PHYs.  It would be much nicer if all
-	 *		PHYs were interrupt-capable like the internal
-	 *		PHY.
-	 *	-	The ACT LED, which shows adapter activity, is
-	 *		driven by the driver, and so must be left on
-	 *		for a short period to power up the LED so it
-	 *		can be seen.  This delay can be changed by
-	 *		changing the TLAN_TIMER_ACT_DELAY in tlan.h,
-	 *		if desired.  100 ms  produces a slightly
-	 *		sluggish response.
-	 *
-	 **************************************************************/
-
-static void TLan_Timer( unsigned long data )
+/***************************************************************
+ *	tlan_timer
+ *
+ *	Returns:
+ *		Nothing
+ *	Parms:
+ *		data	A value given to add timer when
+ *			add_timer was called.
+ *
+ *	This function handles timed functionality for the
+ *	TLAN driver.  The two current timer uses are for
+ *	delaying for autonegotionation and driving the ACT LED.
+ *	-	Autonegotiation requires being allowed about
+ *		2 1/2 seconds before attempting to transmit a
+ *		packet.  It would be a very bad thing to hang
+ *		the kernel this long, so the driver doesn't
+ *		allow transmission 'til after this time, for
+ *		certain PHYs.  It would be much nicer if all
+ *		PHYs were interrupt-capable like the internal
+ *		PHY.
+ *	-	The ACT LED, which shows adapter activity, is
+ *		driven by the driver, and so must be left on
+ *		for a short period to power up the LED so it
+ *		can be seen.  This delay can be changed by
+ *		changing the TLAN_TIMER_ACT_DELAY in tlan.h,
+ *		if desired.  100 ms  produces a slightly
+ *		sluggish response.
+ *
+ **************************************************************/
+
+static void tlan_timer(unsigned long data)
 {
 	struct net_device	*dev = (struct net_device *) data;
-	TLanPrivateInfo	*priv = netdev_priv(dev);
+	struct tlan_priv	*priv = netdev_priv(dev);
 	u32		elapsed;
 	unsigned long	flags = 0;
 
 	priv->timer.function = NULL;
 
-	switch ( priv->timerType ) {
+	switch (priv->timer_type) {
 #ifdef MONITOR
-		case TLAN_TIMER_LINK_BEAT:
-			TLan_PhyMonitor( dev );
-			break;
+	case TLAN_TIMER_LINK_BEAT:
+		tlan_phy_monitor(dev);
+		break;
 #endif
-		case TLAN_TIMER_PHY_PDOWN:
-			TLan_PhyPowerDown( dev );
-			break;
-		case TLAN_TIMER_PHY_PUP:
-			TLan_PhyPowerUp( dev );
-			break;
-		case TLAN_TIMER_PHY_RESET:
-			TLan_PhyReset( dev );
-			break;
-		case TLAN_TIMER_PHY_START_LINK:
-			TLan_PhyStartLink( dev );
-			break;
-		case TLAN_TIMER_PHY_FINISH_AN:
-			TLan_PhyFinishAutoNeg( dev );
-			break;
-		case TLAN_TIMER_FINISH_RESET:
-			TLan_FinishReset( dev );
-			break;
-		case TLAN_TIMER_ACTIVITY:
-			spin_lock_irqsave(&priv->lock, flags);
-			if ( priv->timer.function == NULL ) {
-				elapsed = jiffies - priv->timerSetAt;
-				if ( elapsed >= TLAN_TIMER_ACT_DELAY ) {
-					TLan_DioWrite8( dev->base_addr,
-							TLAN_LED_REG, TLAN_LED_LINK );
-				} else  {
-					priv->timer.function = TLan_Timer;
-					priv->timer.expires = priv->timerSetAt
-						+ TLAN_TIMER_ACT_DELAY;
-					spin_unlock_irqrestore(&priv->lock, flags);
-					add_timer( &priv->timer );
-					break;
-				}
+	case TLAN_TIMER_PHY_PDOWN:
+		tlan_phy_power_down(dev);
+		break;
+	case TLAN_TIMER_PHY_PUP:
+		tlan_phy_power_up(dev);
+		break;
+	case TLAN_TIMER_PHY_RESET:
+		tlan_phy_reset(dev);
+		break;
+	case TLAN_TIMER_PHY_START_LINK:
+		tlan_phy_start_link(dev);
+		break;
+	case TLAN_TIMER_PHY_FINISH_AN:
+		tlan_phy_finish_auto_neg(dev);
+		break;
+	case TLAN_TIMER_FINISH_RESET:
+		tlan_finish_reset(dev);
+		break;
+	case TLAN_TIMER_ACTIVITY:
+		spin_lock_irqsave(&priv->lock, flags);
+		if (priv->timer.function == NULL) {
+			elapsed = jiffies - priv->timer_set_at;
+			if (elapsed >= TLAN_TIMER_ACT_DELAY) {
+				tlan_dio_write8(dev->base_addr,
+						TLAN_LED_REG, TLAN_LED_LINK);
+			} else  {
+				priv->timer.function = tlan_timer;
+				priv->timer.expires = priv->timer_set_at
+					+ TLAN_TIMER_ACT_DELAY;
+				spin_unlock_irqrestore(&priv->lock, flags);
+				add_timer(&priv->timer);
+				break;
 			}
-			spin_unlock_irqrestore(&priv->lock, flags);
-			break;
-		default:
-			break;
+		}
+		spin_unlock_irqrestore(&priv->lock, flags);
+		break;
+	default:
+		break;
 	}
 
-} /* TLan_Timer */
+}
 
 
 
@@ -1919,39 +1951,39 @@ static void TLan_Timer( unsigned long data )
 /*****************************************************************************
 ******************************************************************************
 
-	ThunderLAN Driver Adapter Related Routines
+ThunderLAN driver adapter related routines
 
 ******************************************************************************
 *****************************************************************************/
 
 
-	/***************************************************************
-	 *	TLan_ResetLists
-	 *
-	 *	Returns:
-	 *		Nothing
-	 *	Parms:
-	 *		dev	The device structure with the list
-	 *			stuctures to be reset.
-	 *
-	 *	This routine sets the variables associated with managing
-	 *	the TLAN lists to their initial values.
-	 *
-	 **************************************************************/
-
-static void TLan_ResetLists( struct net_device *dev )
+/***************************************************************
+ *	tlan_reset_lists
+ *
+ *	Returns:
+ *		Nothing
+ *	Parms:
+ *		dev	The device structure with the list
+ *			stuctures to be reset.
+ *
+ *	This routine sets the variables associated with managing
+ *	the TLAN lists to their initial values.
+ *
+ **************************************************************/
+
+static void tlan_reset_lists(struct net_device *dev)
 {
-	TLanPrivateInfo *priv = netdev_priv(dev);
+	struct tlan_priv *priv = netdev_priv(dev);
 	int		i;
-	TLanList	*list;
+	struct tlan_list	*list;
 	dma_addr_t	list_phys;
 	struct sk_buff	*skb;
 
-	priv->txHead = 0;
-	priv->txTail = 0;
-	for ( i = 0; i < TLAN_NUM_TX_LISTS; i++ ) {
-		list = priv->txList + i;
-		list->cStat = TLAN_CSTAT_UNUSED;
+	priv->tx_head = 0;
+	priv->tx_tail = 0;
+	for (i = 0; i < TLAN_NUM_TX_LISTS; i++) {
+		list = priv->tx_list + i;
+		list->c_stat = TLAN_CSTAT_UNUSED;
 		list->buffer[0].address = 0;
 		list->buffer[2].count = 0;
 		list->buffer[2].address = 0;
@@ -1959,169 +1991,169 @@ static void TLan_ResetLists( struct net_device *dev )
 		list->buffer[9].address = 0;
 	}
 
-	priv->rxHead = 0;
-	priv->rxTail = TLAN_NUM_RX_LISTS - 1;
-	for ( i = 0; i < TLAN_NUM_RX_LISTS; i++ ) {
-		list = priv->rxList + i;
-		list_phys = priv->rxListDMA + sizeof(TLanList) * i;
-		list->cStat = TLAN_CSTAT_READY;
-		list->frameSize = TLAN_MAX_FRAME_SIZE;
+	priv->rx_head = 0;
+	priv->rx_tail = TLAN_NUM_RX_LISTS - 1;
+	for (i = 0; i < TLAN_NUM_RX_LISTS; i++) {
+		list = priv->rx_list + i;
+		list_phys = priv->rx_list_dma + sizeof(struct tlan_list)*i;
+		list->c_stat = TLAN_CSTAT_READY;
+		list->frame_size = TLAN_MAX_FRAME_SIZE;
 		list->buffer[0].count = TLAN_MAX_FRAME_SIZE | TLAN_LAST_BUFFER;
 		skb = netdev_alloc_skb_ip_align(dev, TLAN_MAX_FRAME_SIZE + 5);
-		if ( !skb ) {
-			pr_err("TLAN: out of memory for received data.\n" );
+		if (!skb) {
+			pr_err("TLAN: out of memory for received data.\n");
 			break;
 		}
 
-		list->buffer[0].address = pci_map_single(priv->pciDev,
+		list->buffer[0].address = pci_map_single(priv->pci_dev,
 							 skb->data,
 							 TLAN_MAX_FRAME_SIZE,
 							 PCI_DMA_FROMDEVICE);
-		TLan_StoreSKB(list, skb);
+		tlan_store_skb(list, skb);
 		list->buffer[1].count = 0;
 		list->buffer[1].address = 0;
-		list->forward = list_phys + sizeof(TLanList);
+		list->forward = list_phys + sizeof(struct tlan_list);
 	}
 
 	/* in case ran out of memory early, clear bits */
 	while (i < TLAN_NUM_RX_LISTS) {
-		TLan_StoreSKB(priv->rxList + i, NULL);
+		tlan_store_skb(priv->rx_list + i, NULL);
 		++i;
 	}
 	list->forward = 0;
 
-} /* TLan_ResetLists */
+}
 
 
-static void TLan_FreeLists( struct net_device *dev )
+static void tlan_free_lists(struct net_device *dev)
 {
-	TLanPrivateInfo *priv = netdev_priv(dev);
+	struct tlan_priv *priv = netdev_priv(dev);
 	int		i;
-	TLanList	*list;
+	struct tlan_list	*list;
 	struct sk_buff	*skb;
 
-	for ( i = 0; i < TLAN_NUM_TX_LISTS; i++ ) {
-		list = priv->txList + i;
-		skb = TLan_GetSKB(list);
-		if ( skb ) {
+	for (i = 0; i < TLAN_NUM_TX_LISTS; i++) {
+		list = priv->tx_list + i;
+		skb = tlan_get_skb(list);
+		if (skb) {
 			pci_unmap_single(
-				priv->pciDev,
+				priv->pci_dev,
 				list->buffer[0].address,
 				max(skb->len,
 				    (unsigned int)TLAN_MIN_FRAME_SIZE),
 				PCI_DMA_TODEVICE);
-			dev_kfree_skb_any( skb );
+			dev_kfree_skb_any(skb);
 			list->buffer[8].address = 0;
 			list->buffer[9].address = 0;
 		}
 	}
 
-	for ( i = 0; i < TLAN_NUM_RX_LISTS; i++ ) {
-		list = priv->rxList + i;
-		skb = TLan_GetSKB(list);
-		if ( skb ) {
-			pci_unmap_single(priv->pciDev,
+	for (i = 0; i < TLAN_NUM_RX_LISTS; i++) {
+		list = priv->rx_list + i;
+		skb = tlan_get_skb(list);
+		if (skb) {
+			pci_unmap_single(priv->pci_dev,
 					 list->buffer[0].address,
 					 TLAN_MAX_FRAME_SIZE,
 					 PCI_DMA_FROMDEVICE);
-			dev_kfree_skb_any( skb );
+			dev_kfree_skb_any(skb);
 			list->buffer[8].address = 0;
 			list->buffer[9].address = 0;
 		}
 	}
-} /* TLan_FreeLists */
+}
 
 
 
 
-	/***************************************************************
-	 *	TLan_PrintDio
-	 *
-	 *	Returns:
-	 *		Nothing
-	 *	Parms:
-	 *		io_base		Base IO port of the device of
-	 *				which to print DIO registers.
-	 *
-	 *	This function prints out all the internal (DIO)
-	 *	registers of a TLAN chip.
-	 *
-	 **************************************************************/
+/***************************************************************
+ *	tlan_print_dio
+ *
+ *	Returns:
+ *		Nothing
+ *	Parms:
+ *		io_base		Base IO port of the device of
+ *				which to print DIO registers.
+ *
+ *	This function prints out all the internal (DIO)
+ *	registers of a TLAN chip.
+ *
+ **************************************************************/
 
-static void TLan_PrintDio( u16 io_base )
+static void tlan_print_dio(u16 io_base)
 {
 	u32 data0, data1;
 	int	i;
 
-	printk( "TLAN:   Contents of internal registers for io base 0x%04hx.\n",
-		io_base );
-	printk( "TLAN:      Off.  +0         +4\n" );
-	for ( i = 0; i < 0x4C; i+= 8 ) {
-		data0 = TLan_DioRead32( io_base, i );
-		data1 = TLan_DioRead32( io_base, i + 0x4 );
-		printk( "TLAN:      0x%02x  0x%08x 0x%08x\n", i, data0, data1 );
+	pr_info("TLAN:   Contents of internal registers for io base 0x%04hx.\n",
+	       io_base);
+	pr_info("TLAN:      Off.  +0	 +4\n");
+	for (i = 0; i < 0x4C; i += 8) {
+		data0 = tlan_dio_read32(io_base, i);
+		data1 = tlan_dio_read32(io_base, i + 0x4);
+		pr_info("TLAN:      0x%02x  0x%08x 0x%08x\n", i, data0, data1);
 	}
 
-} /* TLan_PrintDio */
+}
 
 
 
 
-	/***************************************************************
-	 *	TLan_PrintList
-	 *
-	 *	Returns:
-	 *		Nothing
-	 *	Parms:
-	 *		list	A pointer to the TLanList structure to
-	 *			be printed.
-	 *		type	A string to designate type of list,
-	 *			"Rx" or "Tx".
-	 *		num	The index of the list.
-	 *
-	 *	This function prints out the contents of the list
-	 *	pointed to by the list parameter.
-	 *
-	 **************************************************************/
+/***************************************************************
+ *	TLan_PrintList
+ *
+ *	Returns:
+ *		Nothing
+ *	Parms:
+ *		list	A pointer to the struct tlan_list structure to
+ *			be printed.
+ *		type	A string to designate type of list,
+ *			"Rx" or "Tx".
+ *		num	The index of the list.
+ *
+ *	This function prints out the contents of the list
+ *	pointed to by the list parameter.
+ *
+ **************************************************************/
 
-static void TLan_PrintList( TLanList *list, char *type, int num)
+static void tlan_print_list(struct tlan_list *list, char *type, int num)
 {
 	int i;
 
-	printk( "TLAN:   %s List %d at %p\n", type, num, list );
-	printk( "TLAN:      Forward    = 0x%08x\n",  list->forward );
-	printk( "TLAN:      CSTAT      = 0x%04hx\n", list->cStat );
-	printk( "TLAN:      Frame Size = 0x%04hx\n", list->frameSize );
-	/* for ( i = 0; i < 10; i++ ) { */
-	for ( i = 0; i < 2; i++ ) {
-		printk( "TLAN:      Buffer[%d].count, addr = 0x%08x, 0x%08x\n",
-			i, list->buffer[i].count, list->buffer[i].address );
+	pr_info("TLAN:   %s List %d at %p\n", type, num, list);
+	pr_info("TLAN:      Forward    = 0x%08x\n",  list->forward);
+	pr_info("TLAN:      CSTAT      = 0x%04hx\n", list->c_stat);
+	pr_info("TLAN:      Frame Size = 0x%04hx\n", list->frame_size);
+	/* for (i = 0; i < 10; i++) { */
+	for (i = 0; i < 2; i++) {
+		pr_info("TLAN:      Buffer[%d].count, addr = 0x%08x, 0x%08x\n",
+		       i, list->buffer[i].count, list->buffer[i].address);
 	}
 
-} /* TLan_PrintList */
+}
 
 
 
 
-	/***************************************************************
-	 *	TLan_ReadAndClearStats
-	 *
-	 *	Returns:
-	 *		Nothing
-	 *	Parms:
-	 *		dev	Pointer to device structure of adapter
-	 *			to which to read stats.
-	 *		record	Flag indicating whether to add
-	 *
-	 *	This functions reads all the internal status registers
-	 *	of the TLAN chip, which clears them as a side effect.
-	 *	It then either adds the values to the device's status
-	 *	struct, or discards them, depending on whether record
-	 *	is TLAN_RECORD (!=0)  or TLAN_IGNORE (==0).
-	 *
-	 **************************************************************/
+/***************************************************************
+ *	tlan_read_and_clear_stats
+ *
+ *	Returns:
+ *		Nothing
+ *	Parms:
+ *		dev	Pointer to device structure of adapter
+ *			to which to read stats.
+ *		record	Flag indicating whether to add
+ *
+ *	This functions reads all the internal status registers
+ *	of the TLAN chip, which clears them as a side effect.
+ *	It then either adds the values to the device's status
+ *	struct, or discards them, depending on whether record
+ *	is TLAN_RECORD (!=0)  or TLAN_IGNORE (==0).
+ *
+ **************************************************************/
 
-static void TLan_ReadAndClearStats( struct net_device *dev, int record )
+static void tlan_read_and_clear_stats(struct net_device *dev, int record)
 {
 	u32		tx_good, tx_under;
 	u32		rx_good, rx_over;
@@ -2129,41 +2161,42 @@ static void TLan_ReadAndClearStats( struct net_device *dev, int record )
 	u32		multi_col, single_col;
 	u32		excess_col, late_col, loss;
 
-	outw( TLAN_GOOD_TX_FRMS, dev->base_addr + TLAN_DIO_ADR );
-	tx_good  = inb( dev->base_addr + TLAN_DIO_DATA );
-	tx_good += inb( dev->base_addr + TLAN_DIO_DATA + 1 ) << 8;
-	tx_good += inb( dev->base_addr + TLAN_DIO_DATA + 2 ) << 16;
-	tx_under = inb( dev->base_addr + TLAN_DIO_DATA + 3 );
-
-	outw( TLAN_GOOD_RX_FRMS, dev->base_addr + TLAN_DIO_ADR );
-	rx_good  = inb( dev->base_addr + TLAN_DIO_DATA );
-	rx_good += inb( dev->base_addr + TLAN_DIO_DATA + 1 ) << 8;
-	rx_good += inb( dev->base_addr + TLAN_DIO_DATA + 2 ) << 16;
-	rx_over  = inb( dev->base_addr + TLAN_DIO_DATA + 3 );
-
-	outw( TLAN_DEFERRED_TX, dev->base_addr + TLAN_DIO_ADR );
-	def_tx  = inb( dev->base_addr + TLAN_DIO_DATA );
-	def_tx += inb( dev->base_addr + TLAN_DIO_DATA + 1 ) << 8;
-	crc     = inb( dev->base_addr + TLAN_DIO_DATA + 2 );
-	code    = inb( dev->base_addr + TLAN_DIO_DATA + 3 );
-
-	outw( TLAN_MULTICOL_FRMS, dev->base_addr + TLAN_DIO_ADR );
-	multi_col   = inb( dev->base_addr + TLAN_DIO_DATA );
-	multi_col  += inb( dev->base_addr + TLAN_DIO_DATA + 1 ) << 8;
-	single_col  = inb( dev->base_addr + TLAN_DIO_DATA + 2 );
-	single_col += inb( dev->base_addr + TLAN_DIO_DATA + 3 ) << 8;
-
-	outw( TLAN_EXCESSCOL_FRMS, dev->base_addr + TLAN_DIO_ADR );
-	excess_col = inb( dev->base_addr + TLAN_DIO_DATA );
-	late_col   = inb( dev->base_addr + TLAN_DIO_DATA + 1 );
-	loss       = inb( dev->base_addr + TLAN_DIO_DATA + 2 );
-
-	if ( record ) {
+	outw(TLAN_GOOD_TX_FRMS, dev->base_addr + TLAN_DIO_ADR);
+	tx_good  = inb(dev->base_addr + TLAN_DIO_DATA);
+	tx_good += inb(dev->base_addr + TLAN_DIO_DATA + 1) << 8;
+	tx_good += inb(dev->base_addr + TLAN_DIO_DATA + 2) << 16;
+	tx_under = inb(dev->base_addr + TLAN_DIO_DATA + 3);
+
+	outw(TLAN_GOOD_RX_FRMS, dev->base_addr + TLAN_DIO_ADR);
+	rx_good  = inb(dev->base_addr + TLAN_DIO_DATA);
+	rx_good += inb(dev->base_addr + TLAN_DIO_DATA + 1) << 8;
+	rx_good += inb(dev->base_addr + TLAN_DIO_DATA + 2) << 16;
+	rx_over  = inb(dev->base_addr + TLAN_DIO_DATA + 3);
+
+	outw(TLAN_DEFERRED_TX, dev->base_addr + TLAN_DIO_ADR);
+	def_tx  = inb(dev->base_addr + TLAN_DIO_DATA);
+	def_tx += inb(dev->base_addr + TLAN_DIO_DATA + 1) << 8;
+	crc     = inb(dev->base_addr + TLAN_DIO_DATA + 2);
+	code    = inb(dev->base_addr + TLAN_DIO_DATA + 3);
+
+	outw(TLAN_MULTICOL_FRMS, dev->base_addr + TLAN_DIO_ADR);
+	multi_col   = inb(dev->base_addr + TLAN_DIO_DATA);
+	multi_col  += inb(dev->base_addr + TLAN_DIO_DATA + 1) << 8;
+	single_col  = inb(dev->base_addr + TLAN_DIO_DATA + 2);
+	single_col += inb(dev->base_addr + TLAN_DIO_DATA + 3) << 8;
+
+	outw(TLAN_EXCESSCOL_FRMS, dev->base_addr + TLAN_DIO_ADR);
+	excess_col = inb(dev->base_addr + TLAN_DIO_DATA);
+	late_col   = inb(dev->base_addr + TLAN_DIO_DATA + 1);
+	loss       = inb(dev->base_addr + TLAN_DIO_DATA + 2);
+
+	if (record) {
 		dev->stats.rx_packets += rx_good;
 		dev->stats.rx_errors  += rx_over + crc + code;
 		dev->stats.tx_packets += tx_good;
 		dev->stats.tx_errors  += tx_under + loss;
-		dev->stats.collisions += multi_col + single_col + excess_col + late_col;
+		dev->stats.collisions += multi_col
+			+ single_col + excess_col + late_col;
 
 		dev->stats.rx_over_errors    += rx_over;
 		dev->stats.rx_crc_errors     += crc;
@@ -2173,39 +2206,39 @@ static void TLan_ReadAndClearStats( struct net_device *dev, int record )
 		dev->stats.tx_carrier_errors += loss;
 	}
 
-} /* TLan_ReadAndClearStats */
+}
 
 
 
 
-	/***************************************************************
-	 *	TLan_Reset
-	 *
-	 *	Returns:
-	 *		0
-	 *	Parms:
-	 *		dev	Pointer to device structure of adapter
-	 *			to be reset.
-	 *
-	 *	This function resets the adapter and it's physical
-	 *	device.  See Chap. 3, pp. 9-10 of the "ThunderLAN
-	 *	Programmer's Guide" for details.  The routine tries to
-	 *	implement what is detailed there, though adjustments
-	 *	have been made.
-	 *
-	 **************************************************************/
+/***************************************************************
+ *	TLan_Reset
+ *
+ *	Returns:
+ *		0
+ *	Parms:
+ *		dev	Pointer to device structure of adapter
+ *			to be reset.
+ *
+ *	This function resets the adapter and it's physical
+ *	device.  See Chap. 3, pp. 9-10 of the "ThunderLAN
+ *	Programmer's Guide" for details.  The routine tries to
+ *	implement what is detailed there, though adjustments
+ *	have been made.
+ *
+ **************************************************************/
 
 static void
-TLan_ResetAdapter( struct net_device *dev )
+tlan_reset_adapter(struct net_device *dev)
 {
-	TLanPrivateInfo	*priv = netdev_priv(dev);
+	struct tlan_priv	*priv = netdev_priv(dev);
 	int		i;
 	u32		addr;
 	u32		data;
 	u8		data8;
 
-	priv->tlanFullDuplex = false;
-	priv->phyOnline=0;
+	priv->tlan_full_duplex = false;
+	priv->phy_online = 0;
 	netif_carrier_off(dev);
 
 /*  1.	Assert reset bit. */
@@ -2216,7 +2249,7 @@ TLan_ResetAdapter( struct net_device *dev )
 
 	udelay(1000);
 
-/*  2.	Turn off interrupts. ( Probably isn't necessary ) */
+/*  2.	Turn off interrupts. (Probably isn't necessary) */
 
 	data = inl(dev->base_addr + TLAN_HOST_CMD);
 	data |= TLAN_HC_INT_OFF;
@@ -2224,207 +2257,208 @@ TLan_ResetAdapter( struct net_device *dev )
 
 /*  3.	Clear AREGs and HASHs. */
 
- 	for ( i = TLAN_AREG_0; i <= TLAN_HASH_2; i += 4 ) {
-		TLan_DioWrite32( dev->base_addr, (u16) i, 0 );
-	}
+	for (i = TLAN_AREG_0; i <= TLAN_HASH_2; i += 4)
+		tlan_dio_write32(dev->base_addr, (u16) i, 0);
 
 /*  4.	Setup NetConfig register. */
 
 	data = TLAN_NET_CFG_1FRAG | TLAN_NET_CFG_1CHAN | TLAN_NET_CFG_PHY_EN;
-	TLan_DioWrite16( dev->base_addr, TLAN_NET_CONFIG, (u16) data );
+	tlan_dio_write16(dev->base_addr, TLAN_NET_CONFIG, (u16) data);
 
 /*  5.	Load Ld_Tmr and Ld_Thr in HOST_CMD. */
 
- 	outl( TLAN_HC_LD_TMR | 0x3f, dev->base_addr + TLAN_HOST_CMD );
- 	outl( TLAN_HC_LD_THR | 0x9, dev->base_addr + TLAN_HOST_CMD );
+	outl(TLAN_HC_LD_TMR | 0x3f, dev->base_addr + TLAN_HOST_CMD);
+	outl(TLAN_HC_LD_THR | 0x9, dev->base_addr + TLAN_HOST_CMD);
 
 /*  6.	Unreset the MII by setting NMRST (in NetSio) to 1. */
 
-	outw( TLAN_NET_SIO, dev->base_addr + TLAN_DIO_ADR );
+	outw(TLAN_NET_SIO, dev->base_addr + TLAN_DIO_ADR);
 	addr = dev->base_addr + TLAN_DIO_DATA + TLAN_NET_SIO;
-	TLan_SetBit( TLAN_NET_SIO_NMRST, addr );
+	tlan_set_bit(TLAN_NET_SIO_NMRST, addr);
 
 /*  7.	Setup the remaining registers. */
 
-	if ( priv->tlanRev >= 0x30 ) {
+	if (priv->tlan_rev >= 0x30) {
 		data8 = TLAN_ID_TX_EOC | TLAN_ID_RX_EOC;
-		TLan_DioWrite8( dev->base_addr, TLAN_INT_DIS, data8 );
+		tlan_dio_write8(dev->base_addr, TLAN_INT_DIS, data8);
 	}
-	TLan_PhyDetect( dev );
+	tlan_phy_detect(dev);
 	data = TLAN_NET_CFG_1FRAG | TLAN_NET_CFG_1CHAN;
 
-	if ( priv->adapter->flags & TLAN_ADAPTER_BIT_RATE_PHY ) {
+	if (priv->adapter->flags & TLAN_ADAPTER_BIT_RATE_PHY) {
 		data |= TLAN_NET_CFG_BIT;
-		if ( priv->aui == 1 ) {
-			TLan_DioWrite8( dev->base_addr, TLAN_ACOMMIT, 0x0a );
-		} else if ( priv->duplex == TLAN_DUPLEX_FULL ) {
-			TLan_DioWrite8( dev->base_addr, TLAN_ACOMMIT, 0x00 );
-			priv->tlanFullDuplex = true;
+		if (priv->aui == 1) {
+			tlan_dio_write8(dev->base_addr, TLAN_ACOMMIT, 0x0a);
+		} else if (priv->duplex == TLAN_DUPLEX_FULL) {
+			tlan_dio_write8(dev->base_addr, TLAN_ACOMMIT, 0x00);
+			priv->tlan_full_duplex = true;
 		} else {
-			TLan_DioWrite8( dev->base_addr, TLAN_ACOMMIT, 0x08 );
+			tlan_dio_write8(dev->base_addr, TLAN_ACOMMIT, 0x08);
 		}
 	}
 
-	if ( priv->phyNum == 0 ) {
+	if (priv->phy_num == 0)
 		data |= TLAN_NET_CFG_PHY_EN;
-	}
-	TLan_DioWrite16( dev->base_addr, TLAN_NET_CONFIG, (u16) data );
+	tlan_dio_write16(dev->base_addr, TLAN_NET_CONFIG, (u16) data);
 
-	if ( priv->adapter->flags & TLAN_ADAPTER_UNMANAGED_PHY ) {
-		TLan_FinishReset( dev );
-	} else {
-		TLan_PhyPowerDown( dev );
-	}
+	if (priv->adapter->flags & TLAN_ADAPTER_UNMANAGED_PHY)
+		tlan_finish_reset(dev);
+	else
+		tlan_phy_power_down(dev);
 
-} /* TLan_ResetAdapter */
+}
 
 
 
 
 static void
-TLan_FinishReset( struct net_device *dev )
+tlan_finish_reset(struct net_device *dev)
 {
-	TLanPrivateInfo	*priv = netdev_priv(dev);
+	struct tlan_priv	*priv = netdev_priv(dev);
 	u8		data;
 	u32		phy;
 	u8		sio;
 	u16		status;
 	u16		partner;
 	u16		tlphy_ctl;
-	u16 		tlphy_par;
+	u16		tlphy_par;
 	u16		tlphy_id1, tlphy_id2;
-	int 		i;
+	int		i;
 
-	phy = priv->phy[priv->phyNum];
+	phy = priv->phy[priv->phy_num];
 
 	data = TLAN_NET_CMD_NRESET | TLAN_NET_CMD_NWRAP;
-	if ( priv->tlanFullDuplex ) {
+	if (priv->tlan_full_duplex)
 		data |= TLAN_NET_CMD_DUPLEX;
-	}
-	TLan_DioWrite8( dev->base_addr, TLAN_NET_CMD, data );
+	tlan_dio_write8(dev->base_addr, TLAN_NET_CMD, data);
 	data = TLAN_NET_MASK_MASK4 | TLAN_NET_MASK_MASK5;
-	if ( priv->phyNum == 0 ) {
+	if (priv->phy_num == 0)
 		data |= TLAN_NET_MASK_MASK7;
-	}
-	TLan_DioWrite8( dev->base_addr, TLAN_NET_MASK, data );
-	TLan_DioWrite16( dev->base_addr, TLAN_MAX_RX, ((1536)+7)&~7 );
-	TLan_MiiReadReg( dev, phy, MII_GEN_ID_HI, &tlphy_id1 );
-	TLan_MiiReadReg( dev, phy, MII_GEN_ID_LO, &tlphy_id2 );
+	tlan_dio_write8(dev->base_addr, TLAN_NET_MASK, data);
+	tlan_dio_write16(dev->base_addr, TLAN_MAX_RX, ((1536)+7)&~7);
+	tlan_mii_read_reg(dev, phy, MII_GEN_ID_HI, &tlphy_id1);
+	tlan_mii_read_reg(dev, phy, MII_GEN_ID_LO, &tlphy_id2);
 
-	if ( ( priv->adapter->flags & TLAN_ADAPTER_UNMANAGED_PHY ) ||
-	     ( priv->aui ) ) {
+	if ((priv->adapter->flags & TLAN_ADAPTER_UNMANAGED_PHY) ||
+	    (priv->aui)) {
 		status = MII_GS_LINK;
-		printk( "TLAN:  %s: Link forced.\n", dev->name );
+		pr_info("TLAN:  %s: Link forced.\n", dev->name);
 	} else {
-		TLan_MiiReadReg( dev, phy, MII_GEN_STS, &status );
-		udelay( 1000 );
-		TLan_MiiReadReg( dev, phy, MII_GEN_STS, &status );
-		if ( (status & MII_GS_LINK) &&
-		     /* We only support link info on Nat.Sem. PHY's */
-			(tlphy_id1 == NAT_SEM_ID1) &&
-			(tlphy_id2 == NAT_SEM_ID2) ) {
-			TLan_MiiReadReg( dev, phy, MII_AN_LPA, &partner );
-			TLan_MiiReadReg( dev, phy, TLAN_TLPHY_PAR, &tlphy_par );
-
-			printk( "TLAN: %s: Link active with ", dev->name );
+		tlan_mii_read_reg(dev, phy, MII_GEN_STS, &status);
+		udelay(1000);
+		tlan_mii_read_reg(dev, phy, MII_GEN_STS, &status);
+		if ((status & MII_GS_LINK) &&
+		    /* We only support link info on Nat.Sem. PHY's */
+		    (tlphy_id1 == NAT_SEM_ID1) &&
+		    (tlphy_id2 == NAT_SEM_ID2)) {
+			tlan_mii_read_reg(dev, phy, MII_AN_LPA, &partner);
+			tlan_mii_read_reg(dev, phy, TLAN_TLPHY_PAR, &tlphy_par);
+
+			pr_info("TLAN: %s: Link active with ", dev->name);
 			if (!(tlphy_par & TLAN_PHY_AN_EN_STAT)) {
-			      	 printk( "forced 10%sMbps %s-Duplex\n",
-					 tlphy_par & TLAN_PHY_SPEED_100 ? "" : "0",
-					 tlphy_par & TLAN_PHY_DUPLEX_FULL ? "Full" : "Half");
+				pr_info("forced 10%sMbps %s-Duplex\n",
+					tlphy_par & TLAN_PHY_SPEED_100
+					? "" : "0",
+					tlphy_par & TLAN_PHY_DUPLEX_FULL
+					? "Full" : "Half");
 			} else {
-				printk( "AutoNegotiation enabled, at 10%sMbps %s-Duplex\n",
-					tlphy_par & TLAN_PHY_SPEED_100 ? "" : "0",
-					tlphy_par & TLAN_PHY_DUPLEX_FULL ? "Full" : "Half");
-				printk("TLAN: Partner capability: ");
-					for (i = 5; i <= 10; i++)
-						if (partner & (1<<i))
-							printk("%s",media[i-5]);
+				pr_info("Autonegotiation enabled, at 10%sMbps %s-Duplex\n",
+					tlphy_par & TLAN_PHY_SPEED_100
+					? "" : "0",
+					tlphy_par & TLAN_PHY_DUPLEX_FULL
+					? "Full" : "half");
+				pr_info("TLAN: Partner capability: ");
+				for (i = 5; i <= 10; i++)
+					if (partner & (1<<i))
+						printk("%s", media[i-5]);
 				printk("\n");
 			}
 
-			TLan_DioWrite8( dev->base_addr, TLAN_LED_REG, TLAN_LED_LINK );
+			tlan_dio_write8(dev->base_addr, TLAN_LED_REG,
+					TLAN_LED_LINK);
 #ifdef MONITOR
 			/* We have link beat..for now anyway */
-	        	priv->link = 1;
-	        	/*Enabling link beat monitoring */
-			TLan_SetTimer( dev, (10*HZ), TLAN_TIMER_LINK_BEAT );
+			priv->link = 1;
+			/*Enabling link beat monitoring */
+			tlan_set_timer(dev, (10*HZ), TLAN_TIMER_LINK_BEAT);
 #endif
 		} else if (status & MII_GS_LINK)  {
-			printk( "TLAN: %s: Link active\n", dev->name );
-			TLan_DioWrite8( dev->base_addr, TLAN_LED_REG, TLAN_LED_LINK );
+			pr_info("TLAN: %s: Link active\n", dev->name);
+			tlan_dio_write8(dev->base_addr, TLAN_LED_REG,
+					TLAN_LED_LINK);
 		}
 	}
 
-	if ( priv->phyNum == 0 ) {
-        	TLan_MiiReadReg( dev, phy, TLAN_TLPHY_CTL, &tlphy_ctl );
-        	tlphy_ctl |= TLAN_TC_INTEN;
-        	TLan_MiiWriteReg( dev, phy, TLAN_TLPHY_CTL, tlphy_ctl );
-        	sio = TLan_DioRead8( dev->base_addr, TLAN_NET_SIO );
-        	sio |= TLAN_NET_SIO_MINTEN;
-        	TLan_DioWrite8( dev->base_addr, TLAN_NET_SIO, sio );
-	}
-
-	if ( status & MII_GS_LINK ) {
-		TLan_SetMac( dev, 0, dev->dev_addr );
-		priv->phyOnline = 1;
-		outb( ( TLAN_HC_INT_ON >> 8 ), dev->base_addr + TLAN_HOST_CMD + 1 );
-		if ( debug >= 1 && debug != TLAN_DEBUG_PROBE ) {
-			outb( ( TLAN_HC_REQ_INT >> 8 ), dev->base_addr + TLAN_HOST_CMD + 1 );
-		}
-		outl( priv->rxListDMA, dev->base_addr + TLAN_CH_PARM );
-		outl( TLAN_HC_GO | TLAN_HC_RT, dev->base_addr + TLAN_HOST_CMD );
+	if (priv->phy_num == 0) {
+		tlan_mii_read_reg(dev, phy, TLAN_TLPHY_CTL, &tlphy_ctl);
+		tlphy_ctl |= TLAN_TC_INTEN;
+		tlan_mii_write_reg(dev, phy, TLAN_TLPHY_CTL, tlphy_ctl);
+		sio = tlan_dio_read8(dev->base_addr, TLAN_NET_SIO);
+		sio |= TLAN_NET_SIO_MINTEN;
+		tlan_dio_write8(dev->base_addr, TLAN_NET_SIO, sio);
+	}
+
+	if (status & MII_GS_LINK) {
+		tlan_set_mac(dev, 0, dev->dev_addr);
+		priv->phy_online = 1;
+		outb((TLAN_HC_INT_ON >> 8), dev->base_addr + TLAN_HOST_CMD + 1);
+		if (debug >= 1 && debug != TLAN_DEBUG_PROBE)
+			outb((TLAN_HC_REQ_INT >> 8),
+			     dev->base_addr + TLAN_HOST_CMD + 1);
+		outl(priv->rx_list_dma, dev->base_addr + TLAN_CH_PARM);
+		outl(TLAN_HC_GO | TLAN_HC_RT, dev->base_addr + TLAN_HOST_CMD);
 		netif_carrier_on(dev);
 	} else {
-		printk( "TLAN: %s: Link inactive, will retry in 10 secs...\n",
-			dev->name );
-		TLan_SetTimer( dev, (10*HZ), TLAN_TIMER_FINISH_RESET );
+		pr_info("TLAN: %s: Link inactive, will retry in 10 secs...\n",
+		       dev->name);
+		tlan_set_timer(dev, (10*HZ), TLAN_TIMER_FINISH_RESET);
 		return;
 	}
-	TLan_SetMulticastList(dev);
+	tlan_set_multicast_list(dev);
 
-} /* TLan_FinishReset */
+}
 
 
 
 
-	/***************************************************************
-	 *	TLan_SetMac
-	 *
-	 *	Returns:
-	 *		Nothing
-	 *	Parms:
-	 *		dev	Pointer to device structure of adapter
-	 *			on which to change the AREG.
-	 *		areg	The AREG to set the address in (0 - 3).
-	 *		mac	A pointer to an array of chars.  Each
-	 *			element stores one byte of the address.
-	 *			IE, it isn't in ascii.
-	 *
-	 *	This function transfers a MAC address to one of the
-	 *	TLAN AREGs (address registers).  The TLAN chip locks
-	 *	the register on writing to offset 0 and unlocks the
-	 *	register after writing to offset 5.  If NULL is passed
-	 *	in mac, then the AREG is filled with 0's.
-	 *
-	 **************************************************************/
+/***************************************************************
+ *	tlan_set_mac
+ *
+ *	Returns:
+ *		Nothing
+ *	Parms:
+ *		dev	Pointer to device structure of adapter
+ *			on which to change the AREG.
+ *		areg	The AREG to set the address in (0 - 3).
+ *		mac	A pointer to an array of chars.  Each
+ *			element stores one byte of the address.
+ *			IE, it isn't in ascii.
+ *
+ *	This function transfers a MAC address to one of the
+ *	TLAN AREGs (address registers).  The TLAN chip locks
+ *	the register on writing to offset 0 and unlocks the
+ *	register after writing to offset 5.  If NULL is passed
+ *	in mac, then the AREG is filled with 0's.
+ *
+ **************************************************************/
 
-static void TLan_SetMac( struct net_device *dev, int areg, char *mac )
+static void tlan_set_mac(struct net_device *dev, int areg, char *mac)
 {
 	int i;
 
 	areg *= 6;
 
-	if ( mac != NULL ) {
-		for ( i = 0; i < 6; i++ )
-			TLan_DioWrite8( dev->base_addr,
-					TLAN_AREG_0 + areg + i, mac[i] );
+	if (mac != NULL) {
+		for (i = 0; i < 6; i++)
+			tlan_dio_write8(dev->base_addr,
+					TLAN_AREG_0 + areg + i, mac[i]);
 	} else {
-		for ( i = 0; i < 6; i++ )
-			TLan_DioWrite8( dev->base_addr,
-					TLAN_AREG_0 + areg + i, 0 );
+		for (i = 0; i < 6; i++)
+			tlan_dio_write8(dev->base_addr,
+					TLAN_AREG_0 + areg + i, 0);
 	}
 
-} /* TLan_SetMac */
+}
 
 
 
@@ -2432,205 +2466,202 @@ static void TLan_SetMac( struct net_device *dev, int areg, char *mac )
 /*****************************************************************************
 ******************************************************************************
 
-	ThunderLAN Driver PHY Layer Routines
+ThunderLAN driver PHY layer routines
 
 ******************************************************************************
 *****************************************************************************/
 
 
 
-	/*********************************************************************
-	 *	TLan_PhyPrint
-	 *
-	 *	Returns:
-	 *		Nothing
-	 *	Parms:
-	 *		dev	A pointer to the device structure of the
-	 *			TLAN device having the PHYs to be detailed.
-	 *
-	 *	This function prints the registers a PHY (aka transceiver).
-	 *
-	 ********************************************************************/
+/*********************************************************************
+ *	tlan_phy_print
+ *
+ *	Returns:
+ *		Nothing
+ *	Parms:
+ *		dev	A pointer to the device structure of the
+ *			TLAN device having the PHYs to be detailed.
+ *
+ *	This function prints the registers a PHY (aka transceiver).
+ *
+ ********************************************************************/
 
-static void TLan_PhyPrint( struct net_device *dev )
+static void tlan_phy_print(struct net_device *dev)
 {
-	TLanPrivateInfo *priv = netdev_priv(dev);
+	struct tlan_priv *priv = netdev_priv(dev);
 	u16 i, data0, data1, data2, data3, phy;
 
-	phy = priv->phy[priv->phyNum];
-
-	if ( priv->adapter->flags & TLAN_ADAPTER_UNMANAGED_PHY ) {
-		printk( "TLAN:   Device %s, Unmanaged PHY.\n", dev->name );
-	} else if ( phy <= TLAN_PHY_MAX_ADDR ) {
-		printk( "TLAN:   Device %s, PHY 0x%02x.\n", dev->name, phy );
-		printk( "TLAN:      Off.  +0     +1     +2     +3\n" );
-                for ( i = 0; i < 0x20; i+= 4 ) {
-			printk( "TLAN:      0x%02x", i );
-			TLan_MiiReadReg( dev, phy, i, &data0 );
-			printk( " 0x%04hx", data0 );
-			TLan_MiiReadReg( dev, phy, i + 1, &data1 );
-			printk( " 0x%04hx", data1 );
-			TLan_MiiReadReg( dev, phy, i + 2, &data2 );
-			printk( " 0x%04hx", data2 );
-			TLan_MiiReadReg( dev, phy, i + 3, &data3 );
-			printk( " 0x%04hx\n", data3 );
+	phy = priv->phy[priv->phy_num];
+
+	if (priv->adapter->flags & TLAN_ADAPTER_UNMANAGED_PHY) {
+		pr_info("TLAN:   Device %s, Unmanaged PHY.\n", dev->name);
+	} else if (phy <= TLAN_PHY_MAX_ADDR) {
+		pr_info("TLAN:   Device %s, PHY 0x%02x.\n", dev->name, phy);
+		pr_info("TLAN:      Off.  +0     +1     +2     +3\n");
+		for (i = 0; i < 0x20; i += 4) {
+			pr_info("TLAN:      0x%02x", i);
+			tlan_mii_read_reg(dev, phy, i, &data0);
+			printk(" 0x%04hx", data0);
+			tlan_mii_read_reg(dev, phy, i + 1, &data1);
+			printk(" 0x%04hx", data1);
+			tlan_mii_read_reg(dev, phy, i + 2, &data2);
+			printk(" 0x%04hx", data2);
+			tlan_mii_read_reg(dev, phy, i + 3, &data3);
+			printk(" 0x%04hx\n", data3);
 		}
 	} else {
-		printk( "TLAN:   Device %s, Invalid PHY.\n", dev->name );
+		pr_info("TLAN:   Device %s, Invalid PHY.\n", dev->name);
 	}
 
-} /* TLan_PhyPrint */
+}
 
 
 
 
-	/*********************************************************************
-	 *	TLan_PhyDetect
-	 *
-	 *	Returns:
-	 *		Nothing
-	 *	Parms:
-	 *		dev	A pointer to the device structure of the adapter
-	 *			for which the PHY needs determined.
-	 *
-	 *	So far I've found that adapters which have external PHYs
-	 *	may also use the internal PHY for part of the functionality.
-	 *	(eg, AUI/Thinnet).  This function finds out if this TLAN
-	 *	chip has an internal PHY, and then finds the first external
-	 *	PHY (starting from address 0) if it exists).
-	 *
-	 ********************************************************************/
+/*********************************************************************
+ *	tlan_phy_detect
+ *
+ *	Returns:
+ *		Nothing
+ *	Parms:
+ *		dev	A pointer to the device structure of the adapter
+ *			for which the PHY needs determined.
+ *
+ *	So far I've found that adapters which have external PHYs
+ *	may also use the internal PHY for part of the functionality.
+ *	(eg, AUI/Thinnet).  This function finds out if this TLAN
+ *	chip has an internal PHY, and then finds the first external
+ *	PHY (starting from address 0) if it exists).
+ *
+ ********************************************************************/
 
-static void TLan_PhyDetect( struct net_device *dev )
+static void tlan_phy_detect(struct net_device *dev)
 {
-	TLanPrivateInfo *priv = netdev_priv(dev);
+	struct tlan_priv *priv = netdev_priv(dev);
 	u16		control;
 	u16		hi;
 	u16		lo;
 	u32		phy;
 
-	if ( priv->adapter->flags & TLAN_ADAPTER_UNMANAGED_PHY ) {
-		priv->phyNum = 0xFFFF;
+	if (priv->adapter->flags & TLAN_ADAPTER_UNMANAGED_PHY) {
+		priv->phy_num = 0xffff;
 		return;
 	}
 
-	TLan_MiiReadReg( dev, TLAN_PHY_MAX_ADDR, MII_GEN_ID_HI, &hi );
+	tlan_mii_read_reg(dev, TLAN_PHY_MAX_ADDR, MII_GEN_ID_HI, &hi);
 
-	if ( hi != 0xFFFF ) {
+	if (hi != 0xffff)
 		priv->phy[0] = TLAN_PHY_MAX_ADDR;
-	} else {
+	else
 		priv->phy[0] = TLAN_PHY_NONE;
-	}
 
 	priv->phy[1] = TLAN_PHY_NONE;
-	for ( phy = 0; phy <= TLAN_PHY_MAX_ADDR; phy++ ) {
-		TLan_MiiReadReg( dev, phy, MII_GEN_CTL, &control );
-		TLan_MiiReadReg( dev, phy, MII_GEN_ID_HI, &hi );
-		TLan_MiiReadReg( dev, phy, MII_GEN_ID_LO, &lo );
-		if ( ( control != 0xFFFF ) ||
-		     ( hi != 0xFFFF ) || ( lo != 0xFFFF ) ) {
-			TLAN_DBG( TLAN_DEBUG_GNRL,
-				  "PHY found at %02x %04x %04x %04x\n",
-				  phy, control, hi, lo );
-			if ( ( priv->phy[1] == TLAN_PHY_NONE ) &&
-			     ( phy != TLAN_PHY_MAX_ADDR ) ) {
+	for (phy = 0; phy <= TLAN_PHY_MAX_ADDR; phy++) {
+		tlan_mii_read_reg(dev, phy, MII_GEN_CTL, &control);
+		tlan_mii_read_reg(dev, phy, MII_GEN_ID_HI, &hi);
+		tlan_mii_read_reg(dev, phy, MII_GEN_ID_LO, &lo);
+		if ((control != 0xffff) ||
+		    (hi != 0xffff) || (lo != 0xffff)) {
+			TLAN_DBG(TLAN_DEBUG_GNRL,
+				 "PHY found at %02x %04x %04x %04x\n",
+				 phy, control, hi, lo);
+			if ((priv->phy[1] == TLAN_PHY_NONE) &&
+			    (phy != TLAN_PHY_MAX_ADDR)) {
 				priv->phy[1] = phy;
 			}
 		}
 	}
 
-	if ( priv->phy[1] != TLAN_PHY_NONE ) {
-		priv->phyNum = 1;
-	} else if ( priv->phy[0] != TLAN_PHY_NONE ) {
-		priv->phyNum = 0;
-	} else {
-		printk( "TLAN:  Cannot initialize device, no PHY was found!\n" );
-	}
+	if (priv->phy[1] != TLAN_PHY_NONE)
+		priv->phy_num = 1;
+	else if (priv->phy[0] != TLAN_PHY_NONE)
+		priv->phy_num = 0;
+	else
+		pr_info("TLAN:  Cannot initialize device, no PHY was found!\n");
 
-} /* TLan_PhyDetect */
+}
 
 
 
 
-static void TLan_PhyPowerDown( struct net_device *dev )
+static void tlan_phy_power_down(struct net_device *dev)
 {
-	TLanPrivateInfo	*priv = netdev_priv(dev);
+	struct tlan_priv	*priv = netdev_priv(dev);
 	u16		value;
 
-	TLAN_DBG( TLAN_DEBUG_GNRL, "%s: Powering down PHY(s).\n", dev->name );
+	TLAN_DBG(TLAN_DEBUG_GNRL, "%s: Powering down PHY(s).\n", dev->name);
 	value = MII_GC_PDOWN | MII_GC_LOOPBK | MII_GC_ISOLATE;
-	TLan_MiiSync( dev->base_addr );
-	TLan_MiiWriteReg( dev, priv->phy[priv->phyNum], MII_GEN_CTL, value );
-	if ( ( priv->phyNum == 0 ) &&
-	     ( priv->phy[1] != TLAN_PHY_NONE ) &&
-	     ( ! ( priv->adapter->flags & TLAN_ADAPTER_USE_INTERN_10 ) ) ) {
-		TLan_MiiSync( dev->base_addr );
-		TLan_MiiWriteReg( dev, priv->phy[1], MII_GEN_CTL, value );
+	tlan_mii_sync(dev->base_addr);
+	tlan_mii_write_reg(dev, priv->phy[priv->phy_num], MII_GEN_CTL, value);
+	if ((priv->phy_num == 0) &&
+	    (priv->phy[1] != TLAN_PHY_NONE) &&
+	    (!(priv->adapter->flags & TLAN_ADAPTER_USE_INTERN_10))) {
+		tlan_mii_sync(dev->base_addr);
+		tlan_mii_write_reg(dev, priv->phy[1], MII_GEN_CTL, value);
 	}
 
 	/* Wait for 50 ms and powerup
 	 * This is abitrary.  It is intended to make sure the
 	 * transceiver settles.
 	 */
-	TLan_SetTimer( dev, (HZ/20), TLAN_TIMER_PHY_PUP );
+	tlan_set_timer(dev, (HZ/20), TLAN_TIMER_PHY_PUP);
 
-} /* TLan_PhyPowerDown */
+}
 
 
 
 
-static void TLan_PhyPowerUp( struct net_device *dev )
+static void tlan_phy_power_up(struct net_device *dev)
 {
-	TLanPrivateInfo	*priv = netdev_priv(dev);
+	struct tlan_priv	*priv = netdev_priv(dev);
 	u16		value;
 
-	TLAN_DBG( TLAN_DEBUG_GNRL, "%s: Powering up PHY.\n", dev->name );
-	TLan_MiiSync( dev->base_addr );
+	TLAN_DBG(TLAN_DEBUG_GNRL, "%s: Powering up PHY.\n", dev->name);
+	tlan_mii_sync(dev->base_addr);
 	value = MII_GC_LOOPBK;
-	TLan_MiiWriteReg( dev, priv->phy[priv->phyNum], MII_GEN_CTL, value );
-	TLan_MiiSync(dev->base_addr);
+	tlan_mii_write_reg(dev, priv->phy[priv->phy_num], MII_GEN_CTL, value);
+	tlan_mii_sync(dev->base_addr);
 	/* Wait for 500 ms and reset the
 	 * transceiver.  The TLAN docs say both 50 ms and
 	 * 500 ms, so do the longer, just in case.
 	 */
-	TLan_SetTimer( dev, (HZ/20), TLAN_TIMER_PHY_RESET );
+	tlan_set_timer(dev, (HZ/20), TLAN_TIMER_PHY_RESET);
 
-} /* TLan_PhyPowerUp */
+}
 
 
 
 
-static void TLan_PhyReset( struct net_device *dev )
+static void tlan_phy_reset(struct net_device *dev)
 {
-	TLanPrivateInfo	*priv = netdev_priv(dev);
+	struct tlan_priv	*priv = netdev_priv(dev);
 	u16		phy;
 	u16		value;
 
-	phy = priv->phy[priv->phyNum];
+	phy = priv->phy[priv->phy_num];
 
-	TLAN_DBG( TLAN_DEBUG_GNRL, "%s: Reseting PHY.\n", dev->name );
-	TLan_MiiSync( dev->base_addr );
+	TLAN_DBG(TLAN_DEBUG_GNRL, "%s: Reseting PHY.\n", dev->name);
+	tlan_mii_sync(dev->base_addr);
 	value = MII_GC_LOOPBK | MII_GC_RESET;
-	TLan_MiiWriteReg( dev, phy, MII_GEN_CTL, value );
-	TLan_MiiReadReg( dev, phy, MII_GEN_CTL, &value );
-	while ( value & MII_GC_RESET ) {
-		TLan_MiiReadReg( dev, phy, MII_GEN_CTL, &value );
-	}
+	tlan_mii_write_reg(dev, phy, MII_GEN_CTL, value);
+	tlan_mii_read_reg(dev, phy, MII_GEN_CTL, &value);
+	while (value & MII_GC_RESET)
+		tlan_mii_read_reg(dev, phy, MII_GEN_CTL, &value);
 
 	/* Wait for 500 ms and initialize.
 	 * I don't remember why I wait this long.
 	 * I've changed this to 50ms, as it seems long enough.
 	 */
-	TLan_SetTimer( dev, (HZ/20), TLAN_TIMER_PHY_START_LINK );
+	tlan_set_timer(dev, (HZ/20), TLAN_TIMER_PHY_START_LINK);
 
-} /* TLan_PhyReset */
+}
 
 
 
 
-static void TLan_PhyStartLink( struct net_device *dev )
+static void tlan_phy_start_link(struct net_device *dev)
 {
-	TLanPrivateInfo	*priv = netdev_priv(dev);
+	struct tlan_priv	*priv = netdev_priv(dev);
 	u16		ability;
 	u16		control;
 	u16		data;
@@ -2638,86 +2669,88 @@ static void TLan_PhyStartLink( struct net_device *dev )
 	u16		status;
 	u16		tctl;
 
-	phy = priv->phy[priv->phyNum];
-	TLAN_DBG( TLAN_DEBUG_GNRL, "%s: Trying to activate link.\n", dev->name );
-	TLan_MiiReadReg( dev, phy, MII_GEN_STS, &status );
-	TLan_MiiReadReg( dev, phy, MII_GEN_STS, &ability );
+	phy = priv->phy[priv->phy_num];
+	TLAN_DBG(TLAN_DEBUG_GNRL, "%s: Trying to activate link.\n", dev->name);
+	tlan_mii_read_reg(dev, phy, MII_GEN_STS, &status);
+	tlan_mii_read_reg(dev, phy, MII_GEN_STS, &ability);
 
-	if ( ( status & MII_GS_AUTONEG ) &&
-	     ( ! priv->aui ) ) {
+	if ((status & MII_GS_AUTONEG) &&
+	    (!priv->aui)) {
 		ability = status >> 11;
-		if ( priv->speed  == TLAN_SPEED_10 &&
-		     priv->duplex == TLAN_DUPLEX_HALF) {
-			TLan_MiiWriteReg( dev, phy, MII_GEN_CTL, 0x0000);
-		} else if ( priv->speed == TLAN_SPEED_10 &&
-			    priv->duplex == TLAN_DUPLEX_FULL) {
-			priv->tlanFullDuplex = true;
-			TLan_MiiWriteReg( dev, phy, MII_GEN_CTL, 0x0100);
-		} else if ( priv->speed == TLAN_SPEED_100 &&
-			    priv->duplex == TLAN_DUPLEX_HALF) {
-			TLan_MiiWriteReg( dev, phy, MII_GEN_CTL, 0x2000);
-		} else if ( priv->speed == TLAN_SPEED_100 &&
-			    priv->duplex == TLAN_DUPLEX_FULL) {
-			priv->tlanFullDuplex = true;
-			TLan_MiiWriteReg( dev, phy, MII_GEN_CTL, 0x2100);
+		if (priv->speed  == TLAN_SPEED_10 &&
+		    priv->duplex == TLAN_DUPLEX_HALF) {
+			tlan_mii_write_reg(dev, phy, MII_GEN_CTL, 0x0000);
+		} else if (priv->speed == TLAN_SPEED_10 &&
+			   priv->duplex == TLAN_DUPLEX_FULL) {
+			priv->tlan_full_duplex = true;
+			tlan_mii_write_reg(dev, phy, MII_GEN_CTL, 0x0100);
+		} else if (priv->speed == TLAN_SPEED_100 &&
+			   priv->duplex == TLAN_DUPLEX_HALF) {
+			tlan_mii_write_reg(dev, phy, MII_GEN_CTL, 0x2000);
+		} else if (priv->speed == TLAN_SPEED_100 &&
+			   priv->duplex == TLAN_DUPLEX_FULL) {
+			priv->tlan_full_duplex = true;
+			tlan_mii_write_reg(dev, phy, MII_GEN_CTL, 0x2100);
 		} else {
 
 			/* Set Auto-Neg advertisement */
-			TLan_MiiWriteReg( dev, phy, MII_AN_ADV, (ability << 5) | 1);
+			tlan_mii_write_reg(dev, phy, MII_AN_ADV,
+					   (ability << 5) | 1);
 			/* Enablee Auto-Neg */
-			TLan_MiiWriteReg( dev, phy, MII_GEN_CTL, 0x1000 );
+			tlan_mii_write_reg(dev, phy, MII_GEN_CTL, 0x1000);
 			/* Restart Auto-Neg */
-			TLan_MiiWriteReg( dev, phy, MII_GEN_CTL, 0x1200 );
+			tlan_mii_write_reg(dev, phy, MII_GEN_CTL, 0x1200);
 			/* Wait for 4 sec for autonegotiation
-		 	* to complete.  The max spec time is less than this
-		 	* but the card need additional time to start AN.
-		 	* .5 sec should be plenty extra.
-		 	*/
-			printk( "TLAN: %s: Starting autonegotiation.\n", dev->name );
-			TLan_SetTimer( dev, (2*HZ), TLAN_TIMER_PHY_FINISH_AN );
+			 * to complete.  The max spec time is less than this
+			 * but the card need additional time to start AN.
+			 * .5 sec should be plenty extra.
+			 */
+			pr_info("TLAN: %s: Starting autonegotiation.\n",
+				dev->name);
+			tlan_set_timer(dev, (2*HZ), TLAN_TIMER_PHY_FINISH_AN);
 			return;
 		}
 
 	}
 
-	if ( ( priv->aui ) && ( priv->phyNum != 0 ) ) {
-		priv->phyNum = 0;
-		data = TLAN_NET_CFG_1FRAG | TLAN_NET_CFG_1CHAN | TLAN_NET_CFG_PHY_EN;
-		TLan_DioWrite16( dev->base_addr, TLAN_NET_CONFIG, data );
-		TLan_SetTimer( dev, (40*HZ/1000), TLAN_TIMER_PHY_PDOWN );
+	if ((priv->aui) && (priv->phy_num != 0)) {
+		priv->phy_num = 0;
+		data = TLAN_NET_CFG_1FRAG | TLAN_NET_CFG_1CHAN
+			| TLAN_NET_CFG_PHY_EN;
+		tlan_dio_write16(dev->base_addr, TLAN_NET_CONFIG, data);
+		tlan_set_timer(dev, (40*HZ/1000), TLAN_TIMER_PHY_PDOWN);
 		return;
-	}  else if ( priv->phyNum == 0 ) {
+	} else if (priv->phy_num == 0) {
 		control = 0;
-        	TLan_MiiReadReg( dev, phy, TLAN_TLPHY_CTL, &tctl );
-		if ( priv->aui ) {
-                	tctl |= TLAN_TC_AUISEL;
+		tlan_mii_read_reg(dev, phy, TLAN_TLPHY_CTL, &tctl);
+		if (priv->aui) {
+			tctl |= TLAN_TC_AUISEL;
 		} else {
-                	tctl &= ~TLAN_TC_AUISEL;
-			if ( priv->duplex == TLAN_DUPLEX_FULL ) {
+			tctl &= ~TLAN_TC_AUISEL;
+			if (priv->duplex == TLAN_DUPLEX_FULL) {
 				control |= MII_GC_DUPLEX;
-				priv->tlanFullDuplex = true;
+				priv->tlan_full_duplex = true;
 			}
-			if ( priv->speed == TLAN_SPEED_100 ) {
+			if (priv->speed == TLAN_SPEED_100)
 				control |= MII_GC_SPEEDSEL;
-			}
 		}
-		TLan_MiiWriteReg( dev, phy, MII_GEN_CTL, control );
-        	TLan_MiiWriteReg( dev, phy, TLAN_TLPHY_CTL, tctl );
+		tlan_mii_write_reg(dev, phy, MII_GEN_CTL, control);
+		tlan_mii_write_reg(dev, phy, TLAN_TLPHY_CTL, tctl);
 	}
 
 	/* Wait for 2 sec to give the transceiver time
 	 * to establish link.
 	 */
-	TLan_SetTimer( dev, (4*HZ), TLAN_TIMER_FINISH_RESET );
+	tlan_set_timer(dev, (4*HZ), TLAN_TIMER_FINISH_RESET);
 
-} /* TLan_PhyStartLink */
+}
 
 
 
 
-static void TLan_PhyFinishAutoNeg( struct net_device *dev )
+static void tlan_phy_finish_auto_neg(struct net_device *dev)
 {
-	TLanPrivateInfo	*priv = netdev_priv(dev);
+	struct tlan_priv	*priv = netdev_priv(dev);
 	u16		an_adv;
 	u16		an_lpa;
 	u16		data;
@@ -2725,115 +2758,118 @@ static void TLan_PhyFinishAutoNeg( struct net_device *dev )
 	u16		phy;
 	u16		status;
 
-	phy = priv->phy[priv->phyNum];
+	phy = priv->phy[priv->phy_num];
 
-	TLan_MiiReadReg( dev, phy, MII_GEN_STS, &status );
-	udelay( 1000 );
-	TLan_MiiReadReg( dev, phy, MII_GEN_STS, &status );
+	tlan_mii_read_reg(dev, phy, MII_GEN_STS, &status);
+	udelay(1000);
+	tlan_mii_read_reg(dev, phy, MII_GEN_STS, &status);
 
-	if ( ! ( status & MII_GS_AUTOCMPLT ) ) {
+	if (!(status & MII_GS_AUTOCMPLT)) {
 		/* Wait for 8 sec to give the process
 		 * more time.  Perhaps we should fail after a while.
 		 */
-		 if (!priv->neg_be_verbose++) {
-			 pr_info("TLAN:  Giving autonegotiation more time.\n");
-		 	 pr_info("TLAN:  Please check that your adapter has\n");
-		 	 pr_info("TLAN:  been properly connected to a HUB or Switch.\n");
-			 pr_info("TLAN:  Trying to establish link in the background...\n");
-		 }
-		TLan_SetTimer( dev, (8*HZ), TLAN_TIMER_PHY_FINISH_AN );
+		if (!priv->neg_be_verbose++) {
+			pr_info("TLAN:  Giving autonegotiation more time.\n");
+			pr_info("TLAN:  Please check that your adapter has\n");
+			pr_info("TLAN:  been properly connected to a HUB or Switch.\n");
+			pr_info("TLAN:  Trying to establish link in the background...\n");
+		}
+		tlan_set_timer(dev, (8*HZ), TLAN_TIMER_PHY_FINISH_AN);
 		return;
 	}
 
-	printk( "TLAN: %s: Autonegotiation complete.\n", dev->name );
-	TLan_MiiReadReg( dev, phy, MII_AN_ADV, &an_adv );
-	TLan_MiiReadReg( dev, phy, MII_AN_LPA, &an_lpa );
+	pr_info("TLAN: %s: Autonegotiation complete.\n", dev->name);
+	tlan_mii_read_reg(dev, phy, MII_AN_ADV, &an_adv);
+	tlan_mii_read_reg(dev, phy, MII_AN_LPA, &an_lpa);
 	mode = an_adv & an_lpa & 0x03E0;
-	if ( mode & 0x0100 ) {
-		priv->tlanFullDuplex = true;
-	} else if ( ! ( mode & 0x0080 ) && ( mode & 0x0040 ) ) {
-		priv->tlanFullDuplex = true;
-	}
-
-	if ( ( ! ( mode & 0x0180 ) ) &&
-	     ( priv->adapter->flags & TLAN_ADAPTER_USE_INTERN_10 ) &&
-	     ( priv->phyNum != 0 ) ) {
-		priv->phyNum = 0;
-		data = TLAN_NET_CFG_1FRAG | TLAN_NET_CFG_1CHAN | TLAN_NET_CFG_PHY_EN;
-		TLan_DioWrite16( dev->base_addr, TLAN_NET_CONFIG, data );
-		TLan_SetTimer( dev, (400*HZ/1000), TLAN_TIMER_PHY_PDOWN );
+	if (mode & 0x0100)
+		priv->tlan_full_duplex = true;
+	else if (!(mode & 0x0080) && (mode & 0x0040))
+		priv->tlan_full_duplex = true;
+
+	if ((!(mode & 0x0180)) &&
+	    (priv->adapter->flags & TLAN_ADAPTER_USE_INTERN_10) &&
+	    (priv->phy_num != 0)) {
+		priv->phy_num = 0;
+		data = TLAN_NET_CFG_1FRAG | TLAN_NET_CFG_1CHAN
+			| TLAN_NET_CFG_PHY_EN;
+		tlan_dio_write16(dev->base_addr, TLAN_NET_CONFIG, data);
+		tlan_set_timer(dev, (400*HZ/1000), TLAN_TIMER_PHY_PDOWN);
 		return;
 	}
 
-	if ( priv->phyNum == 0 ) {
-		if ( ( priv->duplex == TLAN_DUPLEX_FULL ) ||
-		     ( an_adv & an_lpa & 0x0040 ) ) {
-			TLan_MiiWriteReg( dev, phy, MII_GEN_CTL,
-					  MII_GC_AUTOENB | MII_GC_DUPLEX );
-			pr_info("TLAN:  Starting internal PHY with FULL-DUPLEX\n" );
+	if (priv->phy_num == 0) {
+		if ((priv->duplex == TLAN_DUPLEX_FULL) ||
+		    (an_adv & an_lpa & 0x0040)) {
+			tlan_mii_write_reg(dev, phy, MII_GEN_CTL,
+					   MII_GC_AUTOENB | MII_GC_DUPLEX);
+			pr_info("TLAN:  Starting internal PHY with FULL-DUPLEX\n");
 		} else {
-			TLan_MiiWriteReg( dev, phy, MII_GEN_CTL, MII_GC_AUTOENB );
-			pr_info( "TLAN:  Starting internal PHY with HALF-DUPLEX\n" );
+			tlan_mii_write_reg(dev, phy, MII_GEN_CTL,
+					   MII_GC_AUTOENB);
+			pr_info("TLAN:  Starting internal PHY with HALF-DUPLEX\n");
 		}
 	}
 
 	/* Wait for 100 ms.  No reason in partiticular.
 	 */
-	TLan_SetTimer( dev, (HZ/10), TLAN_TIMER_FINISH_RESET );
+	tlan_set_timer(dev, (HZ/10), TLAN_TIMER_FINISH_RESET);
 
-} /* TLan_PhyFinishAutoNeg */
+}
 
 #ifdef MONITOR
 
-        /*********************************************************************
-        *
-        *      TLan_phyMonitor
-        *
-        *      Returns:
-        *              None
-        *
-        *      Params:
-        *              dev             The device structure of this device.
-        *
-        *
-        *      This function monitors PHY condition by reading the status
-        *      register via the MII bus. This can be used to give info
-        *      about link changes (up/down), and possible switch to alternate
-        *      media.
-        *
-        * ******************************************************************/
-
-void TLan_PhyMonitor( struct net_device *dev )
+/*********************************************************************
+ *
+ *     tlan_phy_monitor
+ *
+ *     Returns:
+ *	      None
+ *
+ *     Params:
+ *	      dev	     The device structure of this device.
+ *
+ *
+ *     This function monitors PHY condition by reading the status
+ *     register via the MII bus. This can be used to give info
+ *     about link changes (up/down), and possible switch to alternate
+ *     media.
+ *
+ *******************************************************************/
+
+void tlan_phy_monitor(struct net_device *dev)
 {
-	TLanPrivateInfo *priv = netdev_priv(dev);
+	struct tlan_priv *priv = netdev_priv(dev);
 	u16     phy;
 	u16     phy_status;
 
-	phy = priv->phy[priv->phyNum];
+	phy = priv->phy[priv->phy_num];
 
-        /* Get PHY status register */
-        TLan_MiiReadReg( dev, phy, MII_GEN_STS, &phy_status );
+	/* Get PHY status register */
+	tlan_mii_read_reg(dev, phy, MII_GEN_STS, &phy_status);
 
-        /* Check if link has been lost */
-        if (!(phy_status & MII_GS_LINK)) {
- 	       if (priv->link) {
-		      priv->link = 0;
-	              printk(KERN_DEBUG "TLAN: %s has lost link\n", dev->name);
-		      netif_carrier_off(dev);
-		      TLan_SetTimer( dev, (2*HZ), TLAN_TIMER_LINK_BEAT );
-		      return;
+	/* Check if link has been lost */
+	if (!(phy_status & MII_GS_LINK)) {
+		if (priv->link) {
+			priv->link = 0;
+			printk(KERN_DEBUG "TLAN: %s has lost link\n",
+			       dev->name);
+			netif_carrier_off(dev);
+			tlan_set_timer(dev, (2*HZ), TLAN_TIMER_LINK_BEAT);
+			return;
 		}
 	}
 
-        /* Link restablished? */
-        if ((phy_status & MII_GS_LINK) && !priv->link) {
- 		priv->link = 1;
-        	printk(KERN_DEBUG "TLAN: %s has reestablished link\n", dev->name);
+	/* Link restablished? */
+	if ((phy_status & MII_GS_LINK) && !priv->link) {
+		priv->link = 1;
+		printk(KERN_DEBUG "TLAN: %s has reestablished link\n",
+		       dev->name);
 		netif_carrier_on(dev);
-        }
+	}
 
 	/* Setup a new monitor */
-	TLan_SetTimer( dev, (2*HZ), TLAN_TIMER_LINK_BEAT );
+	tlan_set_timer(dev, (2*HZ), TLAN_TIMER_LINK_BEAT);
 }
 
 #endif /* MONITOR */
@@ -2842,47 +2878,48 @@ void TLan_PhyMonitor( struct net_device *dev )
 /*****************************************************************************
 ******************************************************************************
 
-	ThunderLAN Driver MII Routines
+ThunderLAN driver MII routines
 
-	These routines are based on the information in Chap. 2 of the
-	"ThunderLAN Programmer's Guide", pp. 15-24.
+these routines are based on the information in chap. 2 of the
+"ThunderLAN Programmer's Guide", pp. 15-24.
 
 ******************************************************************************
 *****************************************************************************/
 
 
-	/***************************************************************
-	 *	TLan_MiiReadReg
-	 *
-	 *	Returns:
-	 *		false	if ack received ok
-	 *		true	if no ack received or other error
-	 *
-	 *	Parms:
-	 *		dev		The device structure containing
-	 *				The io address and interrupt count
-	 *				for this device.
-	 *		phy		The address of the PHY to be queried.
-	 *		reg		The register whose contents are to be
-	 *				retrieved.
-	 *		val		A pointer to a variable to store the
-	 *				retrieved value.
-	 *
-	 *	This function uses the TLAN's MII bus to retrieve the contents
-	 *	of a given register on a PHY.  It sends the appropriate info
-	 *	and then reads the 16-bit register value from the MII bus via
-	 *	the TLAN SIO register.
-	 *
-	 **************************************************************/
-
-static bool TLan_MiiReadReg( struct net_device *dev, u16 phy, u16 reg, u16 *val )
+/***************************************************************
+ *	tlan_mii_read_reg
+ *
+ *	Returns:
+ *		false	if ack received ok
+ *		true	if no ack received or other error
+ *
+ *	Parms:
+ *		dev		The device structure containing
+ *				The io address and interrupt count
+ *				for this device.
+ *		phy		The address of the PHY to be queried.
+ *		reg		The register whose contents are to be
+ *				retrieved.
+ *		val		A pointer to a variable to store the
+ *				retrieved value.
+ *
+ *	This function uses the TLAN's MII bus to retrieve the contents
+ *	of a given register on a PHY.  It sends the appropriate info
+ *	and then reads the 16-bit register value from the MII bus via
+ *	the TLAN SIO register.
+ *
+ **************************************************************/
+
+static bool
+tlan_mii_read_reg(struct net_device *dev, u16 phy, u16 reg, u16 *val)
 {
 	u8	nack;
 	u16	sio, tmp;
- 	u32	i;
+	u32	i;
 	bool	err;
 	int	minten;
-	TLanPrivateInfo *priv = netdev_priv(dev);
+	struct tlan_priv *priv = netdev_priv(dev);
 	unsigned long flags = 0;
 
 	err = false;
@@ -2892,48 +2929,48 @@ static bool TLan_MiiReadReg( struct net_device *dev, u16 phy, u16 reg, u16 *val
 	if (!in_irq())
 		spin_lock_irqsave(&priv->lock, flags);
 
-	TLan_MiiSync(dev->base_addr);
+	tlan_mii_sync(dev->base_addr);
 
-	minten = TLan_GetBit( TLAN_NET_SIO_MINTEN, sio );
-	if ( minten )
-		TLan_ClearBit(TLAN_NET_SIO_MINTEN, sio);
+	minten = tlan_get_bit(TLAN_NET_SIO_MINTEN, sio);
+	if (minten)
+		tlan_clear_bit(TLAN_NET_SIO_MINTEN, sio);
 
-	TLan_MiiSendData( dev->base_addr, 0x1, 2 );	/* Start ( 01b ) */
-	TLan_MiiSendData( dev->base_addr, 0x2, 2 );	/* Read  ( 10b ) */
-	TLan_MiiSendData( dev->base_addr, phy, 5 );	/* Device #      */
-	TLan_MiiSendData( dev->base_addr, reg, 5 );	/* Register #    */
+	tlan_mii_send_data(dev->base_addr, 0x1, 2);	/* start (01b) */
+	tlan_mii_send_data(dev->base_addr, 0x2, 2);	/* read  (10b) */
+	tlan_mii_send_data(dev->base_addr, phy, 5);	/* device #      */
+	tlan_mii_send_data(dev->base_addr, reg, 5);	/* register #    */
 
 
-	TLan_ClearBit(TLAN_NET_SIO_MTXEN, sio);		/* Change direction */
+	tlan_clear_bit(TLAN_NET_SIO_MTXEN, sio);	/* change direction */
 
-	TLan_ClearBit(TLAN_NET_SIO_MCLK, sio);		/* Clock Idle bit */
-	TLan_SetBit(TLAN_NET_SIO_MCLK, sio);
-	TLan_ClearBit(TLAN_NET_SIO_MCLK, sio);		/* Wait 300ns */
+	tlan_clear_bit(TLAN_NET_SIO_MCLK, sio);		/* clock idle bit */
+	tlan_set_bit(TLAN_NET_SIO_MCLK, sio);
+	tlan_clear_bit(TLAN_NET_SIO_MCLK, sio);		/* wait 300ns */
 
-	nack = TLan_GetBit(TLAN_NET_SIO_MDATA, sio);	/* Check for ACK */
-	TLan_SetBit(TLAN_NET_SIO_MCLK, sio);		/* Finish ACK */
-	if (nack) {					/* No ACK, so fake it */
+	nack = tlan_get_bit(TLAN_NET_SIO_MDATA, sio);	/* check for ACK */
+	tlan_set_bit(TLAN_NET_SIO_MCLK, sio);		/* finish ACK */
+	if (nack) {					/* no ACK, so fake it */
 		for (i = 0; i < 16; i++) {
-			TLan_ClearBit(TLAN_NET_SIO_MCLK, sio);
-			TLan_SetBit(TLAN_NET_SIO_MCLK, sio);
+			tlan_clear_bit(TLAN_NET_SIO_MCLK, sio);
+			tlan_set_bit(TLAN_NET_SIO_MCLK, sio);
 		}
 		tmp = 0xffff;
 		err = true;
 	} else {					/* ACK, so read data */
 		for (tmp = 0, i = 0x8000; i; i >>= 1) {
-			TLan_ClearBit(TLAN_NET_SIO_MCLK, sio);
-			if (TLan_GetBit(TLAN_NET_SIO_MDATA, sio))
+			tlan_clear_bit(TLAN_NET_SIO_MCLK, sio);
+			if (tlan_get_bit(TLAN_NET_SIO_MDATA, sio))
 				tmp |= i;
-			TLan_SetBit(TLAN_NET_SIO_MCLK, sio);
+			tlan_set_bit(TLAN_NET_SIO_MCLK, sio);
 		}
 	}
 
 
-	TLan_ClearBit(TLAN_NET_SIO_MCLK, sio);		/* Idle cycle */
-	TLan_SetBit(TLAN_NET_SIO_MCLK, sio);
+	tlan_clear_bit(TLAN_NET_SIO_MCLK, sio);		/* idle cycle */
+	tlan_set_bit(TLAN_NET_SIO_MCLK, sio);
 
-	if ( minten )
-		TLan_SetBit(TLAN_NET_SIO_MINTEN, sio);
+	if (minten)
+		tlan_set_bit(TLAN_NET_SIO_MINTEN, sio);
 
 	*val = tmp;
 
@@ -2942,116 +2979,117 @@ static bool TLan_MiiReadReg( struct net_device *dev, u16 phy, u16 reg, u16 *val
 
 	return err;
 
-} /* TLan_MiiReadReg */
+}
 
 
 
 
-	/***************************************************************
-	 *	TLan_MiiSendData
-	 *
-	 *	Returns:
-	 *		Nothing
-	 *	Parms:
-	 *		base_port	The base IO port of the adapter	in
-	 *				question.
-	 *		dev		The address of the PHY to be queried.
-	 *		data		The value to be placed on the MII bus.
-	 *		num_bits	The number of bits in data that are to
-	 *				be placed on the MII bus.
-	 *
-	 *	This function sends on sequence of bits on the MII
-	 *	configuration bus.
-	 *
-	 **************************************************************/
+/***************************************************************
+ *	tlan_mii_send_data
+ *
+ *	Returns:
+ *		Nothing
+ *	Parms:
+ *		base_port	The base IO port of the adapter	in
+ *				question.
+ *		dev		The address of the PHY to be queried.
+ *		data		The value to be placed on the MII bus.
+ *		num_bits	The number of bits in data that are to
+ *				be placed on the MII bus.
+ *
+ *	This function sends on sequence of bits on the MII
+ *	configuration bus.
+ *
+ **************************************************************/
 
-static void TLan_MiiSendData( u16 base_port, u32 data, unsigned num_bits )
+static void tlan_mii_send_data(u16 base_port, u32 data, unsigned num_bits)
 {
 	u16 sio;
 	u32 i;
 
-	if ( num_bits == 0 )
+	if (num_bits == 0)
 		return;
 
-	outw( TLAN_NET_SIO, base_port + TLAN_DIO_ADR );
+	outw(TLAN_NET_SIO, base_port + TLAN_DIO_ADR);
 	sio = base_port + TLAN_DIO_DATA + TLAN_NET_SIO;
-	TLan_SetBit( TLAN_NET_SIO_MTXEN, sio );
+	tlan_set_bit(TLAN_NET_SIO_MTXEN, sio);
 
-	for ( i = ( 0x1 << ( num_bits - 1 ) ); i; i >>= 1 ) {
-		TLan_ClearBit( TLAN_NET_SIO_MCLK, sio );
-		(void) TLan_GetBit( TLAN_NET_SIO_MCLK, sio );
-		if ( data & i )
-			TLan_SetBit( TLAN_NET_SIO_MDATA, sio );
+	for (i = (0x1 << (num_bits - 1)); i; i >>= 1) {
+		tlan_clear_bit(TLAN_NET_SIO_MCLK, sio);
+		(void) tlan_get_bit(TLAN_NET_SIO_MCLK, sio);
+		if (data & i)
+			tlan_set_bit(TLAN_NET_SIO_MDATA, sio);
 		else
-			TLan_ClearBit( TLAN_NET_SIO_MDATA, sio );
-		TLan_SetBit( TLAN_NET_SIO_MCLK, sio );
-		(void) TLan_GetBit( TLAN_NET_SIO_MCLK, sio );
+			tlan_clear_bit(TLAN_NET_SIO_MDATA, sio);
+		tlan_set_bit(TLAN_NET_SIO_MCLK, sio);
+		(void) tlan_get_bit(TLAN_NET_SIO_MCLK, sio);
 	}
 
-} /* TLan_MiiSendData */
+}
 
 
 
 
-	/***************************************************************
-	 *	TLan_MiiSync
-	 *
-	 *	Returns:
-	 *		Nothing
-	 *	Parms:
-	 *		base_port	The base IO port of the adapter in
-	 *				question.
-	 *
-	 *	This functions syncs all PHYs in terms of the MII configuration
-	 *	bus.
-	 *
-	 **************************************************************/
+/***************************************************************
+ *	TLan_MiiSync
+ *
+ *	Returns:
+ *		Nothing
+ *	Parms:
+ *		base_port	The base IO port of the adapter in
+ *				question.
+ *
+ *	This functions syncs all PHYs in terms of the MII configuration
+ *	bus.
+ *
+ **************************************************************/
 
-static void TLan_MiiSync( u16 base_port )
+static void tlan_mii_sync(u16 base_port)
 {
 	int i;
 	u16 sio;
 
-	outw( TLAN_NET_SIO, base_port + TLAN_DIO_ADR );
+	outw(TLAN_NET_SIO, base_port + TLAN_DIO_ADR);
 	sio = base_port + TLAN_DIO_DATA + TLAN_NET_SIO;
 
-	TLan_ClearBit( TLAN_NET_SIO_MTXEN, sio );
-	for ( i = 0; i < 32; i++ ) {
-		TLan_ClearBit( TLAN_NET_SIO_MCLK, sio );
-		TLan_SetBit( TLAN_NET_SIO_MCLK, sio );
+	tlan_clear_bit(TLAN_NET_SIO_MTXEN, sio);
+	for (i = 0; i < 32; i++) {
+		tlan_clear_bit(TLAN_NET_SIO_MCLK, sio);
+		tlan_set_bit(TLAN_NET_SIO_MCLK, sio);
 	}
 
-} /* TLan_MiiSync */
+}
 
 
 
 
-	/***************************************************************
-	 *	TLan_MiiWriteReg
-	 *
-	 *	Returns:
-	 *		Nothing
-	 *	Parms:
-	 *		dev		The device structure for the device
-	 *				to write to.
-	 *		phy		The address of the PHY to be written to.
-	 *		reg		The register whose contents are to be
-	 *				written.
-	 *		val		The value to be written to the register.
-	 *
-	 *	This function uses the TLAN's MII bus to write the contents of a
-	 *	given register on a PHY.  It sends the appropriate info and then
-	 *	writes the 16-bit register value from the MII configuration bus
-	 *	via the TLAN SIO register.
-	 *
-	 **************************************************************/
+/***************************************************************
+ *	tlan_mii_write_reg
+ *
+ *	Returns:
+ *		Nothing
+ *	Parms:
+ *		dev		The device structure for the device
+ *				to write to.
+ *		phy		The address of the PHY to be written to.
+ *		reg		The register whose contents are to be
+ *				written.
+ *		val		The value to be written to the register.
+ *
+ *	This function uses the TLAN's MII bus to write the contents of a
+ *	given register on a PHY.  It sends the appropriate info and then
+ *	writes the 16-bit register value from the MII configuration bus
+ *	via the TLAN SIO register.
+ *
+ **************************************************************/
 
-static void TLan_MiiWriteReg( struct net_device *dev, u16 phy, u16 reg, u16 val )
+static void
+tlan_mii_write_reg(struct net_device *dev, u16 phy, u16 reg, u16 val)
 {
 	u16	sio;
 	int	minten;
 	unsigned long flags = 0;
-	TLanPrivateInfo *priv = netdev_priv(dev);
+	struct tlan_priv *priv = netdev_priv(dev);
 
 	outw(TLAN_NET_SIO, dev->base_addr + TLAN_DIO_ADR);
 	sio = dev->base_addr + TLAN_DIO_DATA + TLAN_NET_SIO;
@@ -3059,30 +3097,30 @@ static void TLan_MiiWriteReg( struct net_device *dev, u16 phy, u16 reg, u16 val
 	if (!in_irq())
 		spin_lock_irqsave(&priv->lock, flags);
 
-	TLan_MiiSync( dev->base_addr );
+	tlan_mii_sync(dev->base_addr);
 
-	minten = TLan_GetBit( TLAN_NET_SIO_MINTEN, sio );
-	if ( minten )
-		TLan_ClearBit( TLAN_NET_SIO_MINTEN, sio );
+	minten = tlan_get_bit(TLAN_NET_SIO_MINTEN, sio);
+	if (minten)
+		tlan_clear_bit(TLAN_NET_SIO_MINTEN, sio);
 
-	TLan_MiiSendData( dev->base_addr, 0x1, 2 );	/* Start ( 01b ) */
-	TLan_MiiSendData( dev->base_addr, 0x1, 2 );	/* Write ( 01b ) */
-	TLan_MiiSendData( dev->base_addr, phy, 5 );	/* Device #      */
-	TLan_MiiSendData( dev->base_addr, reg, 5 );	/* Register #    */
+	tlan_mii_send_data(dev->base_addr, 0x1, 2);	/* start (01b) */
+	tlan_mii_send_data(dev->base_addr, 0x1, 2);	/* write (01b) */
+	tlan_mii_send_data(dev->base_addr, phy, 5);	/* device #      */
+	tlan_mii_send_data(dev->base_addr, reg, 5);	/* register #    */
 
-	TLan_MiiSendData( dev->base_addr, 0x2, 2 );	/* Send ACK */
-	TLan_MiiSendData( dev->base_addr, val, 16 );	/* Send Data */
+	tlan_mii_send_data(dev->base_addr, 0x2, 2);	/* send ACK */
+	tlan_mii_send_data(dev->base_addr, val, 16);	/* send data */
 
-	TLan_ClearBit( TLAN_NET_SIO_MCLK, sio );	/* Idle cycle */
-	TLan_SetBit( TLAN_NET_SIO_MCLK, sio );
+	tlan_clear_bit(TLAN_NET_SIO_MCLK, sio);	/* idle cycle */
+	tlan_set_bit(TLAN_NET_SIO_MCLK, sio);
 
-	if ( minten )
-		TLan_SetBit( TLAN_NET_SIO_MINTEN, sio );
+	if (minten)
+		tlan_set_bit(TLAN_NET_SIO_MINTEN, sio);
 
 	if (!in_irq())
 		spin_unlock_irqrestore(&priv->lock, flags);
 
-} /* TLan_MiiWriteReg */
+}
 
 
 
@@ -3090,229 +3128,226 @@ static void TLan_MiiWriteReg( struct net_device *dev, u16 phy, u16 reg, u16 val
 /*****************************************************************************
 ******************************************************************************
 
-	ThunderLAN Driver Eeprom routines
+ThunderLAN driver eeprom routines
 
-	The Compaq Netelligent 10 and 10/100 cards use a Microchip 24C02A
-	EEPROM.  These functions are based on information in Microchip's
-	data sheet.  I don't know how well this functions will work with
-	other EEPROMs.
+the Compaq netelligent 10 and 10/100 cards use a microchip 24C02A
+EEPROM.  these functions are based on information in microchip's
+data sheet.  I don't know how well this functions will work with
+other Eeproms.
 
 ******************************************************************************
 *****************************************************************************/
 
 
-	/***************************************************************
-	 *	TLan_EeSendStart
-	 *
-	 *	Returns:
-	 *		Nothing
-	 *	Parms:
-	 *		io_base		The IO port base address for the
-	 *				TLAN device with the EEPROM to
-	 *				use.
-	 *
-	 *	This function sends a start cycle to an EEPROM attached
-	 *	to a TLAN chip.
-	 *
-	 **************************************************************/
-
-static void TLan_EeSendStart( u16 io_base )
+/***************************************************************
+ *	tlan_ee_send_start
+ *
+ *	Returns:
+ *		Nothing
+ *	Parms:
+ *		io_base		The IO port base address for the
+ *				TLAN device with the EEPROM to
+ *				use.
+ *
+ *	This function sends a start cycle to an EEPROM attached
+ *	to a TLAN chip.
+ *
+ **************************************************************/
+
+static void tlan_ee_send_start(u16 io_base)
 {
 	u16	sio;
 
-	outw( TLAN_NET_SIO, io_base + TLAN_DIO_ADR );
+	outw(TLAN_NET_SIO, io_base + TLAN_DIO_ADR);
 	sio = io_base + TLAN_DIO_DATA + TLAN_NET_SIO;
 
-	TLan_SetBit( TLAN_NET_SIO_ECLOK, sio );
-	TLan_SetBit( TLAN_NET_SIO_EDATA, sio );
-	TLan_SetBit( TLAN_NET_SIO_ETXEN, sio );
-	TLan_ClearBit( TLAN_NET_SIO_EDATA, sio );
-	TLan_ClearBit( TLAN_NET_SIO_ECLOK, sio );
-
-} /* TLan_EeSendStart */
-
-
-
-
-	/***************************************************************
-	 *	TLan_EeSendByte
-	 *
-	 *	Returns:
-	 *		If the correct ack was received, 0, otherwise 1
-	 *	Parms:	io_base		The IO port base address for the
-	 *				TLAN device with the EEPROM to
-	 *				use.
-	 *		data		The 8 bits of information to
-	 *				send to the EEPROM.
-	 *		stop		If TLAN_EEPROM_STOP is passed, a
-	 *				stop cycle is sent after the
-	 *				byte is sent after the ack is
-	 *				read.
-	 *
-	 *	This function sends a byte on the serial EEPROM line,
-	 *	driving the clock to send each bit. The function then
-	 *	reverses transmission direction and reads an acknowledge
-	 *	bit.
-	 *
-	 **************************************************************/
-
-static int TLan_EeSendByte( u16 io_base, u8 data, int stop )
+	tlan_set_bit(TLAN_NET_SIO_ECLOK, sio);
+	tlan_set_bit(TLAN_NET_SIO_EDATA, sio);
+	tlan_set_bit(TLAN_NET_SIO_ETXEN, sio);
+	tlan_clear_bit(TLAN_NET_SIO_EDATA, sio);
+	tlan_clear_bit(TLAN_NET_SIO_ECLOK, sio);
+
+}
+
+
+
+
+/***************************************************************
+ *	tlan_ee_send_byte
+ *
+ *	Returns:
+ *		If the correct ack was received, 0, otherwise 1
+ *	Parms:	io_base		The IO port base address for the
+ *				TLAN device with the EEPROM to
+ *				use.
+ *		data		The 8 bits of information to
+ *				send to the EEPROM.
+ *		stop		If TLAN_EEPROM_STOP is passed, a
+ *				stop cycle is sent after the
+ *				byte is sent after the ack is
+ *				read.
+ *
+ *	This function sends a byte on the serial EEPROM line,
+ *	driving the clock to send each bit. The function then
+ *	reverses transmission direction and reads an acknowledge
+ *	bit.
+ *
+ **************************************************************/
+
+static int tlan_ee_send_byte(u16 io_base, u8 data, int stop)
 {
 	int	err;
 	u8	place;
 	u16	sio;
 
-	outw( TLAN_NET_SIO, io_base + TLAN_DIO_ADR );
+	outw(TLAN_NET_SIO, io_base + TLAN_DIO_ADR);
 	sio = io_base + TLAN_DIO_DATA + TLAN_NET_SIO;
 
 	/* Assume clock is low, tx is enabled; */
-	for ( place = 0x80; place != 0; place >>= 1 ) {
-		if ( place & data )
-			TLan_SetBit( TLAN_NET_SIO_EDATA, sio );
+	for (place = 0x80; place != 0; place >>= 1) {
+		if (place & data)
+			tlan_set_bit(TLAN_NET_SIO_EDATA, sio);
 		else
-			TLan_ClearBit( TLAN_NET_SIO_EDATA, sio );
-		TLan_SetBit( TLAN_NET_SIO_ECLOK, sio );
-		TLan_ClearBit( TLAN_NET_SIO_ECLOK, sio );
+			tlan_clear_bit(TLAN_NET_SIO_EDATA, sio);
+		tlan_set_bit(TLAN_NET_SIO_ECLOK, sio);
+		tlan_clear_bit(TLAN_NET_SIO_ECLOK, sio);
 	}
-	TLan_ClearBit( TLAN_NET_SIO_ETXEN, sio );
-	TLan_SetBit( TLAN_NET_SIO_ECLOK, sio );
-	err = TLan_GetBit( TLAN_NET_SIO_EDATA, sio );
-	TLan_ClearBit( TLAN_NET_SIO_ECLOK, sio );
-	TLan_SetBit( TLAN_NET_SIO_ETXEN, sio );
+	tlan_clear_bit(TLAN_NET_SIO_ETXEN, sio);
+	tlan_set_bit(TLAN_NET_SIO_ECLOK, sio);
+	err = tlan_get_bit(TLAN_NET_SIO_EDATA, sio);
+	tlan_clear_bit(TLAN_NET_SIO_ECLOK, sio);
+	tlan_set_bit(TLAN_NET_SIO_ETXEN, sio);
 
-	if ( ( ! err ) && stop ) {
+	if ((!err) && stop) {
 		/* STOP, raise data while clock is high */
-		TLan_ClearBit( TLAN_NET_SIO_EDATA, sio );
-		TLan_SetBit( TLAN_NET_SIO_ECLOK, sio );
-		TLan_SetBit( TLAN_NET_SIO_EDATA, sio );
+		tlan_clear_bit(TLAN_NET_SIO_EDATA, sio);
+		tlan_set_bit(TLAN_NET_SIO_ECLOK, sio);
+		tlan_set_bit(TLAN_NET_SIO_EDATA, sio);
 	}
 
 	return err;
 
-} /* TLan_EeSendByte */
-
-
-
-
-	/***************************************************************
-	 *	TLan_EeReceiveByte
-	 *
-	 *	Returns:
-	 *		Nothing
-	 *	Parms:
-	 *		io_base		The IO port base address for the
-	 *				TLAN device with the EEPROM to
-	 *				use.
-	 *		data		An address to a char to hold the
-	 *				data sent from the EEPROM.
-	 *		stop		If TLAN_EEPROM_STOP is passed, a
-	 *				stop cycle is sent after the
-	 *				byte is received, and no ack is
-	 *				sent.
-	 *
-	 *	This function receives 8 bits of data from the EEPROM
-	 *	over the serial link.  It then sends and ack bit, or no
-	 *	ack and a stop bit.  This function is used to retrieve
-	 *	data after the address of a byte in the EEPROM has been
-	 *	sent.
-	 *
-	 **************************************************************/
-
-static void TLan_EeReceiveByte( u16 io_base, u8 *data, int stop )
+}
+
+
+
+
+/***************************************************************
+ *	tlan_ee_receive_byte
+ *
+ *	Returns:
+ *		Nothing
+ *	Parms:
+ *		io_base		The IO port base address for the
+ *				TLAN device with the EEPROM to
+ *				use.
+ *		data		An address to a char to hold the
+ *				data sent from the EEPROM.
+ *		stop		If TLAN_EEPROM_STOP is passed, a
+ *				stop cycle is sent after the
+ *				byte is received, and no ack is
+ *				sent.
+ *
+ *	This function receives 8 bits of data from the EEPROM
+ *	over the serial link.  It then sends and ack bit, or no
+ *	ack and a stop bit.  This function is used to retrieve
+ *	data after the address of a byte in the EEPROM has been
+ *	sent.
+ *
+ **************************************************************/
+
+static void tlan_ee_receive_byte(u16 io_base, u8 *data, int stop)
 {
 	u8  place;
 	u16 sio;
 
-	outw( TLAN_NET_SIO, io_base + TLAN_DIO_ADR );
+	outw(TLAN_NET_SIO, io_base + TLAN_DIO_ADR);
 	sio = io_base + TLAN_DIO_DATA + TLAN_NET_SIO;
 	*data = 0;
 
 	/* Assume clock is low, tx is enabled; */
-	TLan_ClearBit( TLAN_NET_SIO_ETXEN, sio );
-	for ( place = 0x80; place; place >>= 1 ) {
-		TLan_SetBit( TLAN_NET_SIO_ECLOK, sio );
-		if ( TLan_GetBit( TLAN_NET_SIO_EDATA, sio ) )
+	tlan_clear_bit(TLAN_NET_SIO_ETXEN, sio);
+	for (place = 0x80; place; place >>= 1) {
+		tlan_set_bit(TLAN_NET_SIO_ECLOK, sio);
+		if (tlan_get_bit(TLAN_NET_SIO_EDATA, sio))
 			*data |= place;
-		TLan_ClearBit( TLAN_NET_SIO_ECLOK, sio );
+		tlan_clear_bit(TLAN_NET_SIO_ECLOK, sio);
 	}
 
-	TLan_SetBit( TLAN_NET_SIO_ETXEN, sio );
-	if ( ! stop ) {
-		TLan_ClearBit( TLAN_NET_SIO_EDATA, sio );	/* Ack = 0 */
-		TLan_SetBit( TLAN_NET_SIO_ECLOK, sio );
-		TLan_ClearBit( TLAN_NET_SIO_ECLOK, sio );
+	tlan_set_bit(TLAN_NET_SIO_ETXEN, sio);
+	if (!stop) {
+		tlan_clear_bit(TLAN_NET_SIO_EDATA, sio); /* ack = 0 */
+		tlan_set_bit(TLAN_NET_SIO_ECLOK, sio);
+		tlan_clear_bit(TLAN_NET_SIO_ECLOK, sio);
 	} else {
-		TLan_SetBit( TLAN_NET_SIO_EDATA, sio );		/* No ack = 1 (?) */
-		TLan_SetBit( TLAN_NET_SIO_ECLOK, sio );
-		TLan_ClearBit( TLAN_NET_SIO_ECLOK, sio );
+		tlan_set_bit(TLAN_NET_SIO_EDATA, sio);	/* no ack = 1 (?) */
+		tlan_set_bit(TLAN_NET_SIO_ECLOK, sio);
+		tlan_clear_bit(TLAN_NET_SIO_ECLOK, sio);
 		/* STOP, raise data while clock is high */
-		TLan_ClearBit( TLAN_NET_SIO_EDATA, sio );
-		TLan_SetBit( TLAN_NET_SIO_ECLOK, sio );
-		TLan_SetBit( TLAN_NET_SIO_EDATA, sio );
-	}
-
-} /* TLan_EeReceiveByte */
-
-
-
-
-	/***************************************************************
-	 *	TLan_EeReadByte
-	 *
-	 *	Returns:
-	 *		No error = 0, else, the stage at which the error
-	 *		occurred.
-	 *	Parms:
-	 *		io_base		The IO port base address for the
-	 *				TLAN device with the EEPROM to
-	 *				use.
-	 *		ee_addr		The address of the byte in the
-	 *				EEPROM whose contents are to be
-	 *				retrieved.
-	 *		data		An address to a char to hold the
-	 *				data obtained from the EEPROM.
-	 *
-	 *	This function reads a byte of information from an byte
-	 *	cell in the EEPROM.
-	 *
-	 **************************************************************/
-
-static int TLan_EeReadByte( struct net_device *dev, u8 ee_addr, u8 *data )
+		tlan_clear_bit(TLAN_NET_SIO_EDATA, sio);
+		tlan_set_bit(TLAN_NET_SIO_ECLOK, sio);
+		tlan_set_bit(TLAN_NET_SIO_EDATA, sio);
+	}
+
+}
+
+
+
+
+/***************************************************************
+ *	tlan_ee_read_byte
+ *
+ *	Returns:
+ *		No error = 0, else, the stage at which the error
+ *		occurred.
+ *	Parms:
+ *		io_base		The IO port base address for the
+ *				TLAN device with the EEPROM to
+ *				use.
+ *		ee_addr		The address of the byte in the
+ *				EEPROM whose contents are to be
+ *				retrieved.
+ *		data		An address to a char to hold the
+ *				data obtained from the EEPROM.
+ *
+ *	This function reads a byte of information from an byte
+ *	cell in the EEPROM.
+ *
+ **************************************************************/
+
+static int tlan_ee_read_byte(struct net_device *dev, u8 ee_addr, u8 *data)
 {
 	int err;
-	TLanPrivateInfo *priv = netdev_priv(dev);
+	struct tlan_priv *priv = netdev_priv(dev);
 	unsigned long flags = 0;
-	int ret=0;
+	int ret = 0;
 
 	spin_lock_irqsave(&priv->lock, flags);
 
-	TLan_EeSendStart( dev->base_addr );
-	err = TLan_EeSendByte( dev->base_addr, 0xA0, TLAN_EEPROM_ACK );
-	if (err)
-	{
-		ret=1;
+	tlan_ee_send_start(dev->base_addr);
+	err = tlan_ee_send_byte(dev->base_addr, 0xa0, TLAN_EEPROM_ACK);
+	if (err) {
+		ret = 1;
 		goto fail;
 	}
-	err = TLan_EeSendByte( dev->base_addr, ee_addr, TLAN_EEPROM_ACK );
-	if (err)
-	{
-		ret=2;
+	err = tlan_ee_send_byte(dev->base_addr, ee_addr, TLAN_EEPROM_ACK);
+	if (err) {
+		ret = 2;
 		goto fail;
 	}
-	TLan_EeSendStart( dev->base_addr );
-	err = TLan_EeSendByte( dev->base_addr, 0xA1, TLAN_EEPROM_ACK );
-	if (err)
-	{
-		ret=3;
+	tlan_ee_send_start(dev->base_addr);
+	err = tlan_ee_send_byte(dev->base_addr, 0xa1, TLAN_EEPROM_ACK);
+	if (err) {
+		ret = 3;
 		goto fail;
 	}
-	TLan_EeReceiveByte( dev->base_addr, data, TLAN_EEPROM_STOP );
+	tlan_ee_receive_byte(dev->base_addr, data, TLAN_EEPROM_STOP);
 fail:
 	spin_unlock_irqrestore(&priv->lock, flags);
 
 	return ret;
 
-} /* TLan_EeReadByte */
+}
 
 
 
diff --git a/drivers/net/tlan.h b/drivers/net/tlan.h
index 3315ced..5fc98a8 100644
--- a/drivers/net/tlan.h
+++ b/drivers/net/tlan.h
@@ -20,8 +20,8 @@
  ********************************************************************/
 
 
-#include <asm/io.h>
-#include <asm/types.h>
+#include <linux/io.h>
+#include <linux/types.h>
 #include <linux/netdevice.h>
 
 
@@ -40,8 +40,11 @@
 #define TLAN_IGNORE		0
 #define TLAN_RECORD		1
 
-#define TLAN_DBG(lvl, format, args...)	\
-	do { if (debug&lvl) printk(KERN_DEBUG "TLAN: " format, ##args ); } while(0)
+#define TLAN_DBG(lvl, format, args...)					\
+	do {								\
+		if (debug&lvl)						\
+			printk(KERN_DEBUG "TLAN: " format, ##args);	\
+	} while (0)
 
 #define TLAN_DEBUG_GNRL		0x0001
 #define TLAN_DEBUG_TX		0x0002
@@ -50,7 +53,8 @@
 #define TLAN_DEBUG_PROBE	0x0010
 
 #define TX_TIMEOUT		(10*HZ)	 /* We need time for auto-neg */
-#define MAX_TLAN_BOARDS		8	 /* Max number of boards installed at a time */
+#define MAX_TLAN_BOARDS		8	 /* Max number of boards installed
+					    at a time */
 
 
 	/*****************************************************************
@@ -70,13 +74,13 @@
 #define PCI_DEVICE_ID_OLICOM_OC2326			0x0014
 #endif
 
-typedef struct tlan_adapter_entry {
-	u16	vendorId;
-	u16	deviceId;
-	char	*deviceLabel;
+struct tlan_adapter_entry {
+	u16	vendor_id;
+	u16	device_id;
+	char	*device_label;
 	u32	flags;
-	u16	addrOfs;
-} TLanAdapterEntry;
+	u16	addr_ofs;
+};
 
 #define TLAN_ADAPTER_NONE		0x00000000
 #define TLAN_ADAPTER_UNMANAGED_PHY	0x00000001
@@ -129,18 +133,18 @@ typedef struct tlan_adapter_entry {
 #define TLAN_CSTAT_DP_PR	0x0100
 
 
-typedef struct tlan_buffer_ref_tag {
+struct tlan_buffer {
 	u32	count;
 	u32	address;
-} TLanBufferRef;
+};
 
 
-typedef struct tlan_list_tag {
+struct tlan_list {
 	u32		forward;
-	u16		cStat;
-	u16		frameSize;
-	TLanBufferRef	buffer[TLAN_BUFFERS_PER_LIST];
-} TLanList;
+	u16		c_stat;
+	u16		frame_size;
+	struct tlan_buffer buffer[TLAN_BUFFERS_PER_LIST];
+};
 
 
 typedef u8 TLanBuffer[TLAN_MAX_FRAME_SIZE];
@@ -164,49 +168,49 @@ typedef u8 TLanBuffer[TLAN_MAX_FRAME_SIZE];
 	 *
 	 ****************************************************************/
 
-typedef struct tlan_private_tag {
-	struct net_device       *nextDevice;
-	struct pci_dev		*pciDev;
+struct tlan_priv {
+	struct net_device       *next_device;
+	struct pci_dev		*pci_dev;
 	struct net_device       *dev;
-	void			*dmaStorage;
-	dma_addr_t		dmaStorageDMA;
-	unsigned int		dmaSize;
-	u8			*padBuffer;
-	TLanList                *rxList;
-	dma_addr_t		rxListDMA;
-	u8			*rxBuffer;
-	dma_addr_t		rxBufferDMA;
-	u32                     rxHead;
-	u32                     rxTail;
-	u32			rxEocCount;
-	TLanList                *txList;
-	dma_addr_t		txListDMA;
-	u8			*txBuffer;
-	dma_addr_t		txBufferDMA;
-	u32                     txHead;
-	u32                     txInProgress;
-	u32                     txTail;
-	u32			txBusyCount;
-	u32                     phyOnline;
-	u32			timerSetAt;
-	u32			timerType;
+	void			*dma_storage;
+	dma_addr_t		dma_storage_dma;
+	unsigned int		dma_size;
+	u8			*pad_buffer;
+	struct tlan_list	*rx_list;
+	dma_addr_t		rx_list_dma;
+	u8			*rx_buffer;
+	dma_addr_t		rx_buffer_dma;
+	u32			rx_head;
+	u32			rx_tail;
+	u32			rx_eoc_count;
+	struct tlan_list	*tx_list;
+	dma_addr_t		tx_list_dma;
+	u8			*tx_buffer;
+	dma_addr_t		tx_buffer_dma;
+	u32			tx_head;
+	u32			tx_in_progress;
+	u32			tx_tail;
+	u32			tx_busy_count;
+	u32			phy_online;
+	u32			timer_set_at;
+	u32			timer_type;
 	struct timer_list	timer;
 	struct board		*adapter;
-	u32			adapterRev;
+	u32			adapter_rev;
 	u32			aui;
 	u32			debug;
 	u32			duplex;
 	u32			phy[2];
-	u32			phyNum;
+	u32			phy_num;
 	u32			speed;
-	u8			tlanRev;
-	u8			tlanFullDuplex;
+	u8			tlan_rev;
+	u8			tlan_full_duplex;
 	spinlock_t		lock;
 	u8			link;
 	u8			is_eisa;
 	struct work_struct			tlan_tqueue;
 	u8			neg_be_verbose;
-} TLanPrivateInfo;
+};
 
 
 
@@ -247,7 +251,7 @@ typedef struct tlan_private_tag {
 	 ****************************************************************/
 
 #define TLAN_HOST_CMD			0x00
-#define 	TLAN_HC_GO		0x80000000
+#define	TLAN_HC_GO		0x80000000
 #define		TLAN_HC_STOP		0x40000000
 #define		TLAN_HC_ACK		0x20000000
 #define		TLAN_HC_CS_MASK		0x1FE00000
@@ -283,7 +287,7 @@ typedef struct tlan_private_tag {
 #define		TLAN_NET_CMD_TRFRAM	0x02
 #define		TLAN_NET_CMD_TXPACE	0x01
 #define TLAN_NET_SIO			0x01
-#define 	TLAN_NET_SIO_MINTEN	0x80
+#define	TLAN_NET_SIO_MINTEN	0x80
 #define		TLAN_NET_SIO_ECLOK	0x40
 #define		TLAN_NET_SIO_ETXEN	0x20
 #define		TLAN_NET_SIO_EDATA	0x10
@@ -304,7 +308,7 @@ typedef struct tlan_private_tag {
 #define		TLAN_NET_MASK_MASK4	0x10
 #define		TLAN_NET_MASK_RSRVD	0x0F
 #define TLAN_NET_CONFIG			0x04
-#define 	TLAN_NET_CFG_RCLK	0x8000
+#define	TLAN_NET_CFG_RCLK	0x8000
 #define		TLAN_NET_CFG_TCLK	0x4000
 #define		TLAN_NET_CFG_BIT	0x2000
 #define		TLAN_NET_CFG_RXCRC	0x1000
@@ -372,7 +376,7 @@ typedef struct tlan_private_tag {
 /* Generic MII/PHY Registers */
 
 #define MII_GEN_CTL			0x00
-#define 	MII_GC_RESET		0x8000
+#define	MII_GC_RESET		0x8000
 #define		MII_GC_LOOPBK		0x4000
 #define		MII_GC_SPEEDSEL		0x2000
 #define		MII_GC_AUTOENB		0x1000
@@ -397,9 +401,9 @@ typedef struct tlan_private_tag {
 #define		MII_GS_EXTCAP		0x0001
 #define MII_GEN_ID_HI			0x02
 #define MII_GEN_ID_LO			0x03
-#define 	MII_GIL_OUI		0xFC00
-#define 	MII_GIL_MODEL		0x03F0
-#define 	MII_GIL_REVISION	0x000F
+#define	MII_GIL_OUI		0xFC00
+#define	MII_GIL_MODEL		0x03F0
+#define	MII_GIL_REVISION	0x000F
 #define MII_AN_ADV			0x04
 #define MII_AN_LPA			0x05
 #define MII_AN_EXP			0x06
@@ -408,7 +412,7 @@ typedef struct tlan_private_tag {
 
 #define TLAN_TLPHY_ID			0x10
 #define TLAN_TLPHY_CTL			0x11
-#define 	TLAN_TC_IGLINK		0x8000
+#define	TLAN_TC_IGLINK		0x8000
 #define		TLAN_TC_SWAPOL		0x4000
 #define		TLAN_TC_AUISEL		0x2000
 #define		TLAN_TC_SQEEN		0x1000
@@ -435,41 +439,41 @@ typedef struct tlan_private_tag {
 #define LEVEL1_ID1			0x7810
 #define LEVEL1_ID2			0x0000
 
-#define CIRC_INC( a, b ) if ( ++a >= b ) a = 0
+#define CIRC_INC(a, b) if (++a >= b) a = 0
 
 /* Routines to access internal registers. */
 
-static inline u8 TLan_DioRead8(u16 base_addr, u16 internal_addr)
+static inline u8 tlan_dio_read8(u16 base_addr, u16 internal_addr)
 {
 	outw(internal_addr, base_addr + TLAN_DIO_ADR);
 	return inb((base_addr + TLAN_DIO_DATA) + (internal_addr & 0x3));
 
-} /* TLan_DioRead8 */
+}
 
 
 
 
-static inline u16 TLan_DioRead16(u16 base_addr, u16 internal_addr)
+static inline u16 tlan_dio_read16(u16 base_addr, u16 internal_addr)
 {
 	outw(internal_addr, base_addr + TLAN_DIO_ADR);
 	return inw((base_addr + TLAN_DIO_DATA) + (internal_addr & 0x2));
 
-} /* TLan_DioRead16 */
+}
 
 
 
 
-static inline u32 TLan_DioRead32(u16 base_addr, u16 internal_addr)
+static inline u32 tlan_dio_read32(u16 base_addr, u16 internal_addr)
 {
 	outw(internal_addr, base_addr + TLAN_DIO_ADR);
 	return inl(base_addr + TLAN_DIO_DATA);
 
-} /* TLan_DioRead32 */
+}
 
 
 
 
-static inline void TLan_DioWrite8(u16 base_addr, u16 internal_addr, u8 data)
+static inline void tlan_dio_write8(u16 base_addr, u16 internal_addr, u8 data)
 {
 	outw(internal_addr, base_addr + TLAN_DIO_ADR);
 	outb(data, base_addr + TLAN_DIO_DATA + (internal_addr & 0x3));
@@ -479,7 +483,7 @@ static inline void TLan_DioWrite8(u16 base_addr, u16 internal_addr, u8 data)
 
 
 
-static inline void TLan_DioWrite16(u16 base_addr, u16 internal_addr, u16 data)
+static inline void tlan_dio_write16(u16 base_addr, u16 internal_addr, u16 data)
 {
 	outw(internal_addr, base_addr + TLAN_DIO_ADR);
 	outw(data, base_addr + TLAN_DIO_DATA + (internal_addr & 0x2));
@@ -489,16 +493,16 @@ static inline void TLan_DioWrite16(u16 base_addr, u16 internal_addr, u16 data)
 
 
 
-static inline void TLan_DioWrite32(u16 base_addr, u16 internal_addr, u32 data)
+static inline void tlan_dio_write32(u16 base_addr, u16 internal_addr, u32 data)
 {
 	outw(internal_addr, base_addr + TLAN_DIO_ADR);
 	outl(data, base_addr + TLAN_DIO_DATA + (internal_addr & 0x2));
 
 }
 
-#define TLan_ClearBit( bit, port )	outb_p(inb_p(port) & ~bit, port)
-#define TLan_GetBit( bit, port )	((int) (inb_p(port) & bit))
-#define TLan_SetBit( bit, port )	outb_p(inb_p(port) | bit, port)
+#define tlan_clear_bit(bit, port)	outb_p(inb_p(port) & ~bit, port)
+#define tlan_get_bit(bit, port)	((int) (inb_p(port) & bit))
+#define tlan_set_bit(bit, port)	outb_p(inb_p(port) | bit, port)
 
 /*
  * given 6 bytes, view them as 8 6-bit numbers and return the XOR of those
@@ -506,37 +510,37 @@ static inline void TLan_DioWrite32(u16 base_addr, u16 internal_addr, u32 data)
  *
  * The original code was:
  *
- * u32	xor( u32 a, u32 b ) {	return ( ( a && ! b ) || ( ! a && b ) ); }
+ * u32	xor(u32 a, u32 b) {	return ((a && !b ) || (! a && b )); }
  *
- * #define XOR8( a, b, c, d, e, f, g, h )	\
- * 	xor( a, xor( b, xor( c, xor( d, xor( e, xor( f, xor( g, h ) ) ) ) ) ) )
- * #define DA( a, bit )		( ( (u8) a[bit/8] ) & ( (u8) ( 1 << bit%8 ) ) )
+ * #define XOR8(a, b, c, d, e, f, g, h)	\
+ *	xor(a, xor(b, xor(c, xor(d, xor(e, xor(f, xor(g, h)) ) ) ) ) )
+ * #define DA(a, bit)		(( (u8) a[bit/8] ) & ( (u8) (1 << bit%8)) )
  *
- * 	hash  = XOR8( DA(a,0), DA(a, 6), DA(a,12), DA(a,18), DA(a,24),
- * 	              DA(a,30), DA(a,36), DA(a,42) );
- * 	hash |= XOR8( DA(a,1), DA(a, 7), DA(a,13), DA(a,19), DA(a,25),
- * 		      DA(a,31), DA(a,37), DA(a,43) ) << 1;
- * 	hash |= XOR8( DA(a,2), DA(a, 8), DA(a,14), DA(a,20), DA(a,26),
- * 		      DA(a,32), DA(a,38), DA(a,44) ) << 2;
- * 	hash |= XOR8( DA(a,3), DA(a, 9), DA(a,15), DA(a,21), DA(a,27),
- * 		      DA(a,33), DA(a,39), DA(a,45) ) << 3;
- * 	hash |= XOR8( DA(a,4), DA(a,10), DA(a,16), DA(a,22), DA(a,28),
- * 	              DA(a,34), DA(a,40), DA(a,46) ) << 4;
- * 	hash |= XOR8( DA(a,5), DA(a,11), DA(a,17), DA(a,23), DA(a,29),
- * 	              DA(a,35), DA(a,41), DA(a,47) ) << 5;
+ *	hash  = XOR8(DA(a,0), DA(a, 6), DA(a,12), DA(a,18), DA(a,24),
+ *		      DA(a,30), DA(a,36), DA(a,42));
+ *	hash |= XOR8(DA(a,1), DA(a, 7), DA(a,13), DA(a,19), DA(a,25),
+ *		      DA(a,31), DA(a,37), DA(a,43)) << 1;
+ *	hash |= XOR8(DA(a,2), DA(a, 8), DA(a,14), DA(a,20), DA(a,26),
+ *		      DA(a,32), DA(a,38), DA(a,44)) << 2;
+ *	hash |= XOR8(DA(a,3), DA(a, 9), DA(a,15), DA(a,21), DA(a,27),
+ *		      DA(a,33), DA(a,39), DA(a,45)) << 3;
+ *	hash |= XOR8(DA(a,4), DA(a,10), DA(a,16), DA(a,22), DA(a,28),
+ *		      DA(a,34), DA(a,40), DA(a,46)) << 4;
+ *	hash |= XOR8(DA(a,5), DA(a,11), DA(a,17), DA(a,23), DA(a,29),
+ *		      DA(a,35), DA(a,41), DA(a,47)) << 5;
  *
  */
-static inline u32 TLan_HashFunc( const u8 *a )
+static inline u32 tlan_hash_func(const u8 *a)
 {
-        u8     hash;
+	u8     hash;
 
-        hash = (a[0]^a[3]);             /* & 077 */
-        hash ^= ((a[0]^a[3])>>6);       /* & 003 */
-        hash ^= ((a[1]^a[4])<<2);       /* & 074 */
-        hash ^= ((a[1]^a[4])>>4);       /* & 017 */
-        hash ^= ((a[2]^a[5])<<4);       /* & 060 */
-        hash ^= ((a[2]^a[5])>>2);       /* & 077 */
+	hash = (a[0]^a[3]);		/* & 077 */
+	hash ^= ((a[0]^a[3])>>6);	/* & 003 */
+	hash ^= ((a[1]^a[4])<<2);	/* & 074 */
+	hash ^= ((a[1]^a[4])>>4);	/* & 017 */
+	hash ^= ((a[2]^a[5])<<4);	/* & 060 */
+	hash ^= ((a[2]^a[5])>>2);	/* & 077 */
 
-        return hash & 077;
+	return hash & 077;
 }
 #endif
-- 
1.5.6.5

