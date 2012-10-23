From: Paolo Pisati <p.pisati@gmail.com>
Subject: [PATCH 3/6] ksz884x: remove mac address handling as a module parameter
Date: Tue, 23 Oct 2012 19:15:30 +0200
Message-ID: <1351012533-3524-4-git-send-email-p.pisati@gmail.com>
References: <1351012533-3524-1-git-send-email-p.pisati@gmail.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Kristoffer Glembo <kristoffer@gaisler.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:46434 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756995Ab2JWRQf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Oct 2012 13:16:35 -0400
Received: by mail-we0-f174.google.com with SMTP id t9so2160805wey.19
        for <netdev@vger.kernel.org>; Tue, 23 Oct 2012 10:16:34 -0700 (PDT)
In-Reply-To: <1351012533-3524-1-git-send-email-p.pisati@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Paolo Pisati <p.pisati@gmail.com>
---
 drivers/net/ethernet/micrel/ksz884x.c |   57 ---------------------------------
 1 file changed, 57 deletions(-)

diff --git a/drivers/net/ethernet/micrel/ksz884x.c b/drivers/net/ethernet/micrel/ksz884x.c
index 4b9f4bd..c70a1fc 100644
--- a/drivers/net/ethernet/micrel/ksz884x.c
+++ b/drivers/net/ethernet/micrel/ksz884x.c
@@ -6739,9 +6739,6 @@ static void dev_monitor(unsigned long ptr)
 
 static int msg_enable;
 
-static char *macaddr = ":";
-static char *mac1addr = ":";
-
 /*
  * This enables multiple network device mode for KSZ8842, which contains a
  * switch with two physical ports.  Some users like to take control of the
@@ -6852,51 +6849,6 @@ struct platform_info {
 
 static int net_device_present;
 
-static void get_mac_addr(struct dev_info *hw_priv, u8 *macaddr, int port)
-{
-	int i;
-	int j;
-	int got_num;
-	int num;
-
-	i = j = num = got_num = 0;
-	while (j < MAC_ADDR_LEN) {
-		if (macaddr[i]) {
-			int digit;
-
-			got_num = 1;
-			digit = hex_to_bin(macaddr[i]);
-			if (digit >= 0)
-				num = num * 16 + digit;
-			else if (':' == macaddr[i])
-				got_num = 2;
-			else
-				break;
-		} else if (got_num)
-			got_num = 2;
-		else
-			break;
-		if (2 == got_num) {
-			if (MAIN_PORT == port) {
-				hw_priv->hw.override_addr[j++] = (u8) num;
-				hw_priv->hw.override_addr[5] +=
-					hw_priv->hw.id;
-			} else {
-				hw_priv->hw.ksz_switch->other_addr[j++] =
-					(u8) num;
-				hw_priv->hw.ksz_switch->other_addr[5] +=
-					hw_priv->hw.id;
-			}
-			num = got_num = 0;
-		}
-		i++;
-	}
-	if (MAC_ADDR_LEN == j) {
-		if (MAIN_PORT == port)
-			hw_priv->hw.mac_override = 1;
-	}
-}
-
 #define KS884X_DMA_MASK			(~0x0UL)
 
 static void read_other_addr(struct ksz_hw *hw)
@@ -7050,9 +7002,6 @@ static int __devinit pcidev_init(struct pci_dev *pdev,
 	for (i = 0; i < TOTAL_PORT_NUM; i++)
 		init_waitqueue_head(&hw_priv->counter[i].counter);
 
-	if (macaddr[0] != ':')
-		get_mac_addr(hw_priv, macaddr, MAIN_PORT);
-
 	/* Read MAC address and initialize override address if not overrided. */
 	hw_read_addr(hw);
 
@@ -7060,8 +7009,6 @@ static int __devinit pcidev_init(struct pci_dev *pdev,
 	if (hw->dev_count > 1) {
 		memcpy(sw->other_addr, hw->override_addr, MAC_ADDR_LEN);
 		read_other_addr(hw);
-		if (mac1addr[0] != ':')
-			get_mac_addr(hw_priv, mac1addr, OTHER_PORT);
 	}
 
 	hw_setup(hw);
@@ -7276,13 +7223,9 @@ MODULE_LICENSE("GPL");
 module_param_named(message, msg_enable, int, 0);
 MODULE_PARM_DESC(message, "Message verbosity level (0=none, 31=all)");
 
-module_param(macaddr, charp, 0);
-module_param(mac1addr, charp, 0);
 module_param(fast_aging, int, 0);
 module_param(multi_dev, int, 0);
 module_param(stp, int, 0);
-MODULE_PARM_DESC(macaddr, "MAC address");
-MODULE_PARM_DESC(mac1addr, "Second MAC address");
 MODULE_PARM_DESC(fast_aging, "Fast aging");
 MODULE_PARM_DESC(multi_dev, "Multiple device interfaces");
 MODULE_PARM_DESC(stp, "STP support");
-- 
1.7.9.5
