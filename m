From: Christoph Egger <siccegge@cs.fau.de>
Subject: [PATCH 04/11] Removing dead CASSINI_MULTICAST_REG_WRITE
Date: Wed, 14 Jul 2010 14:40:53 +0200
Message-ID: <8cf1d83f53d9cedceaf7567deb03bb211a83d32c.1279110895.git.siccegge__46517.617282416$1279111378$gmane$org@cs.fau.de>
References: <cover.1279110894.git.siccegge@cs.fau.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vamos-dev@i4.informatik.uni-erlangen.de
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Jiri Pirko <jpirko@redhat.com>, Joe Perches <joe@perches.com>,
	Stephen Hemminger <shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from faui40.informatik.uni-erlangen.de ([131.188.34.40]:43605 "EHLO
	faui40.informatik.uni-erlangen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754734Ab0GNMkz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jul 2010 08:40:55 -0400
Content-Disposition: inline
In-Reply-To: <cover.1279110894.git.siccegge@cs.fau.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CASSINI_MULTICAST_REG_WRITE doesn't exist in Kconfig, therefore
removing all references for it from the source code.

Signed-off-by: Christoph Egger <siccegge@cs.fau.de>
---
 drivers/net/cassini.c |   20 +-------------------
 1 files changed, 1 insertions(+), 19 deletions(-)

diff --git a/drivers/net/cassini.c b/drivers/net/cassini.c
index 04a03f7..0d911ba 100644
--- a/drivers/net/cassini.c
+++ b/drivers/net/cassini.c
@@ -3063,9 +3063,6 @@ static void cas_init_mac(struct cas *cp)
 {
 	unsigned char *e = &cp->dev->dev_addr[0];
 	int i;
-#ifdef CONFIG_CASSINI_MULTICAST_REG_WRITE
-	u32 rxcfg;
-#endif
 	cas_mac_reset(cp);
 
 	/* setup core arbitration weight register */
@@ -3133,23 +3130,8 @@ static void cas_init_mac(struct cas *cp)
 	writel(0xc200, cp->regs + REG_MAC_ADDRN(43));
 	writel(0x0180, cp->regs + REG_MAC_ADDRN(44));
 
-#ifndef CONFIG_CASSINI_MULTICAST_REG_WRITE
 	cp->mac_rx_cfg = cas_setup_multicast(cp);
-#else
-	/* WTZ: Do what Adrian did in cas_set_multicast. Doing
-	 * a writel does not seem to be necessary because Cassini
-	 * seems to preserve the configuration when we do the reset.
-	 * If the chip is in trouble, though, it is not clear if we
-	 * can really count on this behavior. cas_set_multicast uses
-	 * spin_lock_irqsave, but we are called only in cas_init_hw and
-	 * cas_init_hw is protected by cas_lock_all, which calls
-	 * spin_lock_irq (so it doesn't need to save the flags, and
-	 * we should be OK for the writel, as that is the only
-	 * difference).
-	 */
-	cp->mac_rx_cfg = rxcfg = cas_setup_multicast(cp);
-	writel(rxcfg, cp->regs + REG_MAC_RX_CFG);
-#endif
+
 	spin_lock(&cp->stat_lock[N_TX_RINGS]);
 	cas_clear_mac_err(cp);
 	spin_unlock(&cp->stat_lock[N_TX_RINGS]);
-- 
1.7.0.4

