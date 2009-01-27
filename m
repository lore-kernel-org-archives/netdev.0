From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: [PATCH] fec: remove empty functions
Date: Tue, 27 Jan 2009 11:39:57 +0100
Message-ID: <1233052804-31228-3-git-send-email-s.hauer@pengutronix.de>
References: <1233052804-31228-1-git-send-email-s.hauer@pengutronix.de>
 <1233052804-31228-2-git-send-email-s.hauer@pengutronix.de>
Cc: Greg Ungerer <gerg@snapgear.com>,
	frederic rodo <fred.rodo@gmail.com>,
	Sascha Hauer <s.hauer@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:47133 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753039AbZA0KmJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 05:42:09 -0500
In-Reply-To: <1233052804-31228-2-git-send-email-s.hauer@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are some architecture specific functions which are all
empty. Remove them.

Signed-off-by: Sascha Hauer <s.hauer@pengutronix.de>
---
 drivers/net/fec.c |   65 -----------------------------------------------------
 1 files changed, 0 insertions(+), 65 deletions(-)

diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index b754f60..f913c97 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -1306,10 +1306,6 @@ static void __inline__ fec_get_mac(struct net_device *dev)
 		 dev->dev_addr[ETH_ALEN-1] = fec_mac_default[ETH_ALEN-1] + fep->index;
 }
 
-static void __inline__ fec_enable_phy_intr(void)
-{
-}
-
 static void __inline__ fec_disable_phy_intr(void)
 {
 	volatile unsigned long *icrp;
@@ -1325,17 +1321,6 @@ static void __inline__ fec_phy_ack_intr(void)
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
@@ -1475,10 +1460,6 @@ static void __inline__ fec_get_mac(struct net_device *dev)
 		dev->dev_addr[ETH_ALEN-1] = fec_mac_default[ETH_ALEN-1] + fep->index;
 }
 
-static void __inline__ fec_enable_phy_intr(void)
-{
-}
-
 static void __inline__ fec_disable_phy_intr(void)
 {
 }
@@ -1487,17 +1468,6 @@ static void __inline__ fec_phy_ack_intr(void)
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
@@ -1596,10 +1566,6 @@ static void __inline__ fec_get_mac(struct net_device *dev)
 		dev->dev_addr[ETH_ALEN-1] = fec_mac_default[ETH_ALEN-1] + fep->index;
 }
 
-static void __inline__ fec_enable_phy_intr(void)
-{
-}
-
 static void __inline__ fec_disable_phy_intr(void)
 {
 }
@@ -1608,14 +1574,6 @@ static void __inline__ fec_phy_ack_intr(void)
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
@@ -1735,10 +1693,6 @@ static void __inline__ fec_get_mac(struct net_device *dev)
 		dev->dev_addr[ETH_ALEN-1] = fec_mac_default[ETH_ALEN-1] + fep->index;
 }
 
-static void __inline__ fec_enable_phy_intr(void)
-{
-}
-
 static void __inline__ fec_disable_phy_intr(void)
 {
 }
@@ -1747,17 +1701,6 @@ static void __inline__ fec_phy_ack_intr(void)
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
@@ -2199,8 +2142,6 @@ int __init fec_enet_init(struct net_device *dev)
 	cbd_base = (cbd_t *)mem_addr;
 	/* XXX: missing check for allocation failure */
 
-	fec_uncache(mem_addr);
-
 	/* Set receive and transmit descriptor base.
 	*/
 	fep->rx_bd_base = cbd_base;
@@ -2221,8 +2162,6 @@ int __init fec_enet_init(struct net_device *dev)
 		mem_addr = __get_free_page(GFP_KERNEL);
 		/* XXX: missing check for allocation failure */
 
-		fec_uncache(mem_addr);
-
 		/* Initialize the BD for every fragment in the page.
 		*/
 		for (j=0; j<FEC_ENET_RX_FRPPG; j++) {
@@ -2338,7 +2277,6 @@ fec_restart(struct net_device *dev, int duplex)
 	/* Clear any outstanding interrupt.
 	*/
 	fecp->fec_ievent = 0xffc00000;
-	fec_enable_phy_intr();
 
 	/* Set station address.
 	*/
@@ -2353,8 +2291,6 @@ fec_restart(struct net_device *dev, int duplex)
 	*/
 	fecp->fec_r_buff_size = PKT_MAXBLR_SIZE;
 
-	fec_localhw_setup();
-
 	/* Set receive and transmit descriptor base.
 	*/
 	fecp->fec_r_des_start = __pa((uint)(fep->rx_bd_base));
@@ -2460,7 +2396,6 @@ fec_stop(struct net_device *dev)
 	/* Clear outstanding MII command interrupts.
 	*/
 	fecp->fec_ievent = FEC_ENET_MII;
-	fec_enable_phy_intr();
 
 	fecp->fec_imask = FEC_ENET_MII;
 	fecp->fec_mii_speed = fep->phy_speed;
-- 
1.5.6.5

