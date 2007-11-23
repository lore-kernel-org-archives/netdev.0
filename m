From: Pekka J Enberg <penberg@cs.helsinki.fi>
Subject: [PATCH 6/8] ipg: remove some internal comments
Date: Fri, 23 Nov 2007 10:19:50 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0711231019330.18378@sbz-30.cs.Helsinki.FI>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: romieu@fr.zoreil.com, sorbica@icplus.com.tw, jesse@icplus.com.tw,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:42513 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752808AbXKWITv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Nov 2007 03:19:51 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pekka Enberg <penberg@cs.helsinki.fi>

This removes some now useless comments that were added when the driver was
developed out-of-tree.

Cc: Francois Romieu <romieu@fr.zoreil.com>
Cc: Sorbica Shieh <sorbica@icplus.com.tw>
Cc: Jesse Huang <jesse@icplus.com.tw>
Signed-off-by: Pekka Enberg <penberg@cs.helsinki.fi>
---
 drivers/net/ipg.c |   11 ++++-------
 drivers/net/ipg.h |   10 ++++------
 2 files changed, 8 insertions(+), 13 deletions(-)

Index: linux-2.6/drivers/net/ipg.c
===================================================================
--- linux-2.6.orig/drivers/net/ipg.c
+++ linux-2.6/drivers/net/ipg.c
@@ -373,7 +373,6 @@ static void mdio_write(struct net_device
 	}
 }
 
-/* Set LED_Mode JES20040127EEPROM */
 static void ipg_set_led_mode(struct net_device *dev)
 {
 	struct ipg_nic_private *sp = netdev_priv(dev);
@@ -395,7 +394,6 @@ static void ipg_set_led_mode(struct net_
 	ipg_w32(mode, ASIC_CTRL);
 }
 
-/* Set PHYSet JES20040127EEPROM */
 static void ipg_set_phy_set(struct net_device *dev)
 {
 	struct ipg_nic_private *sp = netdev_priv(dev);
@@ -414,7 +412,7 @@ static int ipg_reset(struct net_device *
 	 * register as specified by the 'resetflags' input
 	 * parameter.
 	 */
-	void __iomem *ioaddr = ipg_ioaddr(dev);	//JES20040127EEPROM:
+	void __iomem *ioaddr = ipg_ioaddr(dev);
 	unsigned int timeout_count = 0;
 
 	IPG_DEBUG_MSG("_reset\n");
@@ -429,10 +427,10 @@ static int ipg_reset(struct net_device *
 		if (++timeout_count > IPG_AC_RESET_TIMEOUT)
 			return -ETIME;
 	}
-	/* Set LED Mode in Asic Control JES20040127EEPROM */
+	/* Set LED Mode in Asic Control */
 	ipg_set_led_mode(dev);
 
-	/* Set PHYSet Register Value JES20040127EEPROM */
+	/* Set PHYSet Register Value */
 	ipg_set_phy_set(dev);
 	return 0;
 }
@@ -2018,7 +2016,6 @@ static void ipg_set_phy_default_param(un
 	}
 }
 
-/* JES20040127EEPROM */
 static int read_eeprom(struct net_device *dev, int eep_addr)
 {
 	void __iomem *ioaddr = ipg_ioaddr(dev);
@@ -2085,7 +2082,7 @@ static int ipg_hw_init(struct net_device
 	unsigned int i;
 	int rc;
 
-	/* Read/Write and Reset EEPROM Value Jesse20040128EEPROM_VALUE */
+	/* Read/Write and Reset EEPROM Value */
 	/* Read LED Mode Configuration from EEPROM */
 	sp->LED_Mode = read_eeprom(dev, 6);
 
Index: linux-2.6/drivers/net/ipg.h
===================================================================
--- linux-2.6.orig/drivers/net/ipg.h
+++ linux-2.6/drivers/net/ipg.h
@@ -79,7 +79,7 @@ enum ipg_regs {
 	TX_STATUS		= 0x60,
 	MAC_CTRL		= 0x6c,
 	VLAN_TAG		= 0x70, // Unused
-	PHY_SET			= 0x75,	// JES20040127EEPROM
+	PHY_SET			= 0x75,
 	PHY_CTRL		= 0x76,
 	STATION_ADDRESS_0	= 0x78,
 	STATION_ADDRESS_1	= 0x7a,
@@ -312,7 +312,7 @@ enum ipg_regs {
 #define IPG_RM_RECEIVEMULTICASTHASH     0x10
 #define IPG_RM_RECEIVEIPMULTICAST       0x20
 
-/* PhySet JES20040127EEPROM*/
+/* PhySet */
 #define IPG_PS_MEM_LENB9B               0x01
 #define IPG_PS_MEM_LEN9                 0x02
 #define IPG_PS_NON_COMPDET              0x04
@@ -369,8 +369,8 @@ enum ipg_regs {
 #define IPG_AC_RST_OUT                  0x01000000
 #define IPG_AC_INT_REQUEST              0x02000000
 #define IPG_AC_RESET_BUSY               0x04000000
-#define IPG_AC_LED_SPEED                0x08000000	//JES20040127EEPROM
-#define IPG_AC_LED_MODE_BIT_1           0x20000000	//JES20040127EEPROM
+#define IPG_AC_LED_SPEED                0x08000000
+#define IPG_AC_LED_MODE_BIT_1           0x20000000
 
 /* EepromCtrl */
 #define IPG_EC_RSVD_MASK                0x83FF
@@ -785,7 +785,6 @@ struct ipg_nic_private {
 	unsigned int tx_dirty;
 	unsigned int rx_current;
 	unsigned int rx_dirty;
-// Add by Grace 2005/05/19
 #ifdef JUMBO_FRAME
 	struct SJumbo Jumbo;
 #endif
@@ -796,7 +795,6 @@ struct ipg_nic_private {
 	spinlock_t lock;
 	int tenmbpsmode;
 
-	/*Jesse20040128EEPROM_VALUE */
 	u16 LED_Mode;
 	u16 station_addr[3];	/* Station Address in EEPROM Reg 0x10..0x12 */
 
