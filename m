From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: Third (final?) release of Sun Neptune driver
Date: Fri, 05 Oct 2007 16:42:26 -0700 (PDT)
Message-ID: <20071005.164226.118517655.davem@davemloft.net>
References: <20071005.031209.57156822.davem@davemloft.net>
	<20071005084036.52dc943c@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ariel.Hendel@sun.com, greg.onufer@sun.com,
	jeff@garzik.org, Ashley.Saulsbury@sun.com, Matheos.Worku@sun.com
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49218
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753234AbXJEXm1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Oct 2007 19:42:27 -0400
In-Reply-To: <20071005084036.52dc943c@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Fri, 5 Oct 2007 08:40:36 -0700

> Output of checkpatch.pl for your patch:

I've made cures for the cases which make sense, thanks!

commit 2ab9ea48dae8fd46e525460700e7e497c9cb92f8
Author: David S. Miller <davem@sunset.davemloft.net>
Date:   Fri Oct 5 16:41:00 2007 -0700

    [NIU]: Fix some checkpatch caught coding style issues.
    
    1) Remove initializing of statics to 0/NULL.
    2) Use tabs instead of spaces.
    3) Kill trailing spaces.
    4) Cure lines over 80 columns.
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index 63c902d..da15a91 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -88,7 +88,7 @@ MODULE_DEVICE_TABLE(pci, niu_pci_tbl);
 
 #define NIU_MSG_DEFAULT (NETIF_MSG_DRV | NETIF_MSG_PROBE | NETIF_MSG_LINK)
 
-static int niu_debug = 0;
+static int niu_debug;
 static int debug = -1;
 module_param(debug, int, 0);
 MODULE_PARM_DESC(debug, "NIU debug level");
@@ -532,7 +532,6 @@ static int esr_reset(struct niu *np)
 		return err;
 	udelay(200);
 
-	
 	err = mdio_write(np, np->port, NIU_ESR_DEV_ADDR,
 			 ESR_RXTX_RESET_CTRL_L, 0xffff);
 	if (err)
@@ -1825,7 +1824,7 @@ static int hash_write(struct niu *np, unsigned long partition,
 
 	return 0;
 }
-		       
+
 static void fflp_reset(struct niu *np)
 {
 	u64 val;
@@ -4138,7 +4137,7 @@ static void niu_init_tx_xmac(struct niu *np, u64 min, u64 max)
 	u64 val;
 
 	val = nr64_mac(XMAC_MIN);
-	val &= ~(XMAC_MIN_TX_MIN_PKT_SIZE | 
+	val &= ~(XMAC_MIN_TX_MIN_PKT_SIZE |
 		 XMAC_MIN_RX_MIN_PKT_SIZE);
 	val |= (min << XMAC_MIN_RX_MIN_PKT_SIZE_SHFT);
 	val |= (min << XMAC_MIN_TX_MIN_PKT_SIZE_SHFT);
@@ -5355,7 +5354,7 @@ static void niu_get_drvinfo(struct net_device *dev,
 
 static int niu_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
-  	struct niu *np = netdev_priv(dev);
+	struct niu *np = netdev_priv(dev);
 	struct niu_link_config *lp;
 
 	lp = &np->link_config;
@@ -5683,9 +5682,9 @@ static int niu_ldg_assign_ldn(struct niu *np, struct niu_parent *parent,
 
 	if (np->parent->plat_type == PLAT_TYPE_NIU) {
 		/* On N2 NIU, the ldn-->ldg assignments are setup and fixed by
-		 * the firmware, and we're not supposed to change them.  Validate
-		 * the mapping, because if it's wrong we probably won't get any
-		 * interrupts and that's painful to debug.
+		 * the firmware, and we're not supposed to change them.
+		 * Validate the mapping, because if it's wrong we probably
+		 * won't get any interrupts and that's painful to debug.
 		 */
 		if (nr64(LDG_NUM(ldn)) != ldg) {
 			dev_err(np->device, PFX "Port %u, mis-matched "
@@ -5788,14 +5787,14 @@ static int __devinit niu_pci_eeprom_read16_swp(struct niu *np, u32 off)
 	int err = niu_pci_eeprom_read(np, off);
 	u16 val;
 
-	if (err < 0) {
+	if (err < 0)
 		return err;
-	}
+
 	val = (err & 0xff);
 	err = niu_pci_eeprom_read(np, off + 1);
-	if (err < 0) {
+	if (err < 0)
 		return err;
-	}
+
 	val |= (err & 0xff) << 8;
 
 	return val;
@@ -5867,7 +5866,7 @@ static int __devinit niu_pci_vpd_scan_props(struct niu *np,
 		char namebuf[64];
 		u8 *prop_buf;
 		int max_len;
-		
+
 		if (found_mask == FOUND_MASK_ALL) {
 			niu_vpd_parse_version(np);
 			return 1;
@@ -6027,7 +6026,8 @@ static u32 __devinit niu_pci_vpd_offset(struct niu *np)
 	return 0;
 }
 
-static int __devinit niu_phy_type_prop_decode(struct niu *np, const char *phy_prop)
+static int __devinit niu_phy_type_prop_decode(struct niu *np,
+					      const char *phy_prop)
 {
 	if (!strcmp(phy_prop, "mif")) {
 		/* 1G copper, MII */
@@ -7339,17 +7339,16 @@ static const struct niu_ops niu_pci_ops = {
 
 static void __devinit niu_driver_version(void)
 {
-	static int niu_version_printed = 0;
+	static int niu_version_printed;
 
 	if (niu_version_printed++ == 0)
 		pr_info("%s", version);
 }
 
-static struct net_device * __devinit niu_alloc_and_init(struct device *gen_dev,
-							struct pci_dev *pdev,
-							struct of_device *op,
-							const struct niu_ops *ops,
-							u8 port)
+static struct net_device * __devinit niu_alloc_and_init(
+	struct device *gen_dev, struct pci_dev *pdev,
+	struct of_device *op, const struct niu_ops *ops,
+	u8 port)
 {
 	struct net_device *dev = alloc_etherdev(sizeof(struct niu));
 	struct niu *np;
@@ -7722,7 +7721,8 @@ static unsigned long res_size(struct resource *r)
 	return r->end - r->start + 1UL;
 }
 
-static int __devinit niu_of_probe(struct of_device *op, const struct of_device_id *match)
+static int __devinit niu_of_probe(struct of_device *op,
+				  const struct of_device_id *match)
 {
 	union niu_parent_id parent_id;
 	struct net_device *dev;
