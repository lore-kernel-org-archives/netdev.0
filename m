From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: [PATCH] fec: remove empty functions
Date: Wed, 14 Jan 2009 17:09:09 +0100
Message-ID: <1231949353-29630-3-git-send-email-s.hauer@pengutronix.de>
References: <1231949353-29630-1-git-send-email-s.hauer@pengutronix.de>
 <1231949353-29630-2-git-send-email-s.hauer@pengutronix.de>
Cc: Sebastian Siewior <bigeasy@linutronix.de>,
	Greg Ungerer <gerg@uclinux.org>,
	Sascha Hauer <s.hauer@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:57020 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756633AbZANQJ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 11:09:59 -0500
In-Reply-To: <1231949353-29630-2-git-send-email-s.hauer@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are some architecture specific functions which are all
empty. Remove them.

Signed-off-by: Sascha Hauer <s.hauer@pengutronix.de>
---
 drivers/net/fec.c |   65 -----------------------------------------------------
 1 files changed, 0 insertions(+), 65 deletions(-)

diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index 95785ef..812d8be 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -1304,10 +1304,6 @@ static void __inline__ fec_get_mac(struct net_device *dev)
 		 dev->dev_addr[ETH_ALEN-1] = fec_mac_default[ETH_ALEN-1] + fep->index;
 }
 
-static void __inline__ fec_enable_phy_intr(void)
-{
-}
-
 static void __inline__ fec_disable_phy_intr(void)
 {
 	volatile unsigned long *icrp;
@@ -1323,17 +1319,6 @@ static void __inline__ fec_phy_ack_intr(void)
 	*icrp = 0x0d000000;
 }
 
-static void __inline__ fec_localhw_setup(void)
-{
-}
-
-/*
- *	Do not need to make region uncached on 5272.
- */
-static void __inline__ fec_uncache(unsigned long addr)
-{
-}
-
 /* ------------------------------------------------------------------------- */
 
 #elif defined(CONFIG_M523x) || defined(CONFIG_M527x) || defined(CONFIG_M528x)
@@ -1473,10 +1458,6 @@ static void __inline__ fec_get_mac(struct net_device *dev)
 		dev->dev_addr[ETH_ALEN-1] = fec_mac_default[ETH_ALEN-1] + fep->index;
 }
 
-static void __inline__ fec_enable_phy_intr(void)
-{
-}
-
 static void __inline__ fec_disable_phy_intr(void)
 {
 }
@@ -1485,17 +1466,6 @@ static void __inline__ fec_phy_ack_intr(void)
 {
 }
 
-static void __inline__ fec_localhw_setup(void)
-{
-}
-
-/*
- *	Do not need to make region uncached on 5272.
- */
-static void __inline__ fec_uncache(unsigned long addr)
-{
-}
-
 /* ------------------------------------------------------------------------- */
 
 #elif defined(CONFIG_M520x)
@@ -1594,10 +1564,6 @@ static void __inline__ fec_get_mac(struct net_device *dev)
 		dev->dev_addr[ETH_ALEN-1] = fec_mac_default[ETH_ALEN-1] + fep->index;
 }
 
-static void __inline__ fec_enable_phy_intr(void)
-{
-}
-
 static void __inline__ fec_disable_phy_intr(void)
 {
 }
@@ -1606,14 +1572,6 @@ static void __inline__ fec_phy_ack_intr(void)
 {
 }
 
-static void __inline__ fec_localhw_setup(void)
-{
-}
-
-static void __inline__ fec_uncache(unsigned long addr)
-{
-}
-
 /* ------------------------------------------------------------------------- */
 
 #elif defined(CONFIG_M532x)
@@ -1733,10 +1691,6 @@ static void __inline__ fec_get_mac(struct net_device *dev)
 		dev->dev_addr[ETH_ALEN-1] = fec_mac_default[ETH_ALEN-1] + fep->index;
 }
 
-static void __inline__ fec_enable_phy_intr(void)
-{
-}
-
 static void __inline__ fec_disable_phy_intr(void)
 {
 }
@@ -1745,17 +1699,6 @@ static void __inline__ fec_phy_ack_intr(void)
 {
 }
 
-static void __inline__ fec_localhw_setup(void)
-{
-}
-
-/*
- *	Do not need to make region uncached on 532x.
- */
-static void __inline__ fec_uncache(unsigned long addr)
-{
-}
-
 #endif
 
 /* ------------------------------------------------------------------------- */
@@ -2197,8 +2140,6 @@ int __init fec_enet_init(struct net_device *dev)
 	cbd_base = (cbd_t *)mem_addr;
 	/* XXX: missing check for allocation failure */
 
-	fec_uncache(mem_addr);
-
 	/* Set receive and transmit descriptor base.
 	*/
 	fep->rx_bd_base = cbd_base;
@@ -2219,8 +2160,6 @@ int __init fec_enet_init(struct net_device *dev)
 		mem_addr = __get_free_page(GFP_KERNEL);
 		/* XXX: missing check for allocation failure */
 
-		fec_uncache(mem_addr);
-
 		/* Initialize the BD for every fragment in the page.
 		*/
 		for (j=0; j<FEC_ENET_RX_FRPPG; j++) {
@@ -2336,7 +2275,6 @@ fec_restart(struct net_device *dev, int duplex)
 	/* Clear any outstanding interrupt.
 	*/
 	fecp->fec_ievent = 0xffc00000;
-	fec_enable_phy_intr();
 
 	/* Set station address.
 	*/
@@ -2351,8 +2289,6 @@ fec_restart(struct net_device *dev, int duplex)
 	*/
 	fecp->fec_r_buff_size = PKT_MAXBLR_SIZE;
 
-	fec_localhw_setup();
-
 	/* Set receive and transmit descriptor base.
 	*/
 	fecp->fec_r_des_start = __pa((uint)(fep->rx_bd_base));
@@ -2458,7 +2394,6 @@ fec_stop(struct net_device *dev)
 	/* Clear outstanding MII command interrupts.
 	*/
 	fecp->fec_ievent = FEC_ENET_MII;
-	fec_enable_phy_intr();
 
 	fecp->fec_imask = FEC_ENET_MII;
 	fecp->fec_mii_speed = fep->phy_speed;
-- 
1.5.6.5

