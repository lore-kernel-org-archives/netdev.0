From: Harvey Harrison <harvey.harrison@gmail.com>
Subject: [PATCH] dnet: mark methods static and annotate for correct endianness
Date: Wed, 13 Oct 2010 01:20:34 -0700
Message-ID: <1286958034-19372-1-git-send-email-harvey.harrison@gmail.com>
Cc: Harvey Harrison <harvey.harrison@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:36850 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753308Ab0JMIUq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Oct 2010 04:20:46 -0400
Received: by pvc7 with SMTP id 7so295424pvc.19
        for <netdev@vger.kernel.org>; Wed, 13 Oct 2010 01:20:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Their doesn't appear to be bugs with the endianness handling here, just get the
annotations right to keep sparse happy.

Suppresses the following sparse warnings:
drivers/net/dnet.c:30:5: warning: symbol 'dnet_readw_mac' was not declared. Should it be static?
drivers/net/dnet.c:49:6: warning: symbol 'dnet_writew_mac' was not declared. Should it be static?
drivers/net/dnet.c:364:5: warning: symbol 'dnet_phy_marvell_fixup' was not declared. Should it be static?
drivers/net/dnet.c:66:13: warning: incorrect type in assignment (different base types)
drivers/net/dnet.c:66:13:    expected unsigned short [unsigned] [usertype] tmp
drivers/net/dnet.c:66:13:    got restricted __be16 [usertype] <noident>
drivers/net/dnet.c:68:13: warning: incorrect type in assignment (different base types)
drivers/net/dnet.c:68:13:    expected unsigned short [unsigned] [usertype] tmp
drivers/net/dnet.c:68:13:    got restricted __be16 [usertype] <noident>
drivers/net/dnet.c:70:13: warning: incorrect type in assignment (different base types)
drivers/net/dnet.c:70:13:    expected unsigned short [unsigned] [usertype] tmp
drivers/net/dnet.c:70:13:    got restricted __be16 [usertype] <noident>
drivers/net/dnet.c:92:27: warning: cast to restricted __be16
drivers/net/dnet.c:94:33: warning: cast to restricted __be16
drivers/net/dnet.c:96:33: warning: cast to restricted __be16

Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
---
 drivers/net/dnet.c |   18 +++++++++---------
 1 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/dnet.c b/drivers/net/dnet.c
index 7c07575..9d8a20b 100644
--- a/drivers/net/dnet.c
+++ b/drivers/net/dnet.c
@@ -27,7 +27,7 @@
 #undef DEBUG
 
 /* function for reading internal MAC register */
-u16 dnet_readw_mac(struct dnet *bp, u16 reg)
+static u16 dnet_readw_mac(struct dnet *bp, u16 reg)
 {
 	u16 data_read;
 
@@ -46,7 +46,7 @@ u16 dnet_readw_mac(struct dnet *bp, u16 reg)
 }
 
 /* function for writing internal MAC register */
-void dnet_writew_mac(struct dnet *bp, u16 reg, u16 val)
+static void dnet_writew_mac(struct dnet *bp, u16 reg, u16 val)
 {
 	/* load data to write */
 	dnet_writel(bp, val, MACREG_DATA);
@@ -63,11 +63,11 @@ static void __dnet_set_hwaddr(struct dnet *bp)
 {
 	u16 tmp;
 
-	tmp = cpu_to_be16(*((u16 *) bp->dev->dev_addr));
+	tmp = be16_to_cpup((__be16 *)bp->dev->dev_addr);
 	dnet_writew_mac(bp, DNET_INTERNAL_MAC_ADDR_0_REG, tmp);
-	tmp = cpu_to_be16(*((u16 *) (bp->dev->dev_addr + 2)));
+	tmp = be16_to_cpup((__be16 *)(bp->dev->dev_addr + 2));
 	dnet_writew_mac(bp, DNET_INTERNAL_MAC_ADDR_1_REG, tmp);
-	tmp = cpu_to_be16(*((u16 *) (bp->dev->dev_addr + 4)));
+	tmp = be16_to_cpup((__be16 *)(bp->dev->dev_addr + 4));
 	dnet_writew_mac(bp, DNET_INTERNAL_MAC_ADDR_2_REG, tmp);
 }
 
@@ -89,11 +89,11 @@ static void __devinit dnet_get_hwaddr(struct dnet *bp)
 	 * Mac_addr[15:0]).
 	 */
 	tmp = dnet_readw_mac(bp, DNET_INTERNAL_MAC_ADDR_0_REG);
-	*((u16 *) addr) = be16_to_cpu(tmp);
+	*((__be16 *)addr) = cpu_to_be16(tmp);
 	tmp = dnet_readw_mac(bp, DNET_INTERNAL_MAC_ADDR_1_REG);
-	*((u16 *) (addr + 2)) = be16_to_cpu(tmp);
+	*((__be16 *)(addr + 2)) = cpu_to_be16(tmp);
 	tmp = dnet_readw_mac(bp, DNET_INTERNAL_MAC_ADDR_2_REG);
-	*((u16 *) (addr + 4)) = be16_to_cpu(tmp);
+	*((__be16 *)(addr + 4)) = cpu_to_be16(tmp);
 
 	if (is_valid_ether_addr(addr))
 		memcpy(bp->dev->dev_addr, addr, sizeof(addr));
@@ -361,7 +361,7 @@ err_out:
 }
 
 /* For Neptune board: LINK1000 as Link LED and TX as activity LED */
-int dnet_phy_marvell_fixup(struct phy_device *phydev)
+static int dnet_phy_marvell_fixup(struct phy_device *phydev)
 {
 	return phy_write(phydev, 0x18, 0x4148);
 }
-- 
1.7.1

