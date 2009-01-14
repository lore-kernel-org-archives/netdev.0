From: Sascha Hauer <s.hauer@pengutronix.de>
Subject: [PATCH] fec: remove unused #else branches
Date: Wed, 14 Jan 2009 17:09:08 +0100
Message-ID: <1231949353-29630-2-git-send-email-s.hauer@pengutronix.de>
References: <1231949353-29630-1-git-send-email-s.hauer@pengutronix.de>
Cc: Sebastian Siewior <bigeasy@linutronix.de>,
	Greg Ungerer <gerg@uclinux.org>,
	Sascha Hauer <s.hauer@pengutronix.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:56989 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753129AbZANQJg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 11:09:36 -0500
In-Reply-To: <1231949353-29630-1-git-send-email-s.hauer@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The #else branches throughout this driver belong to a PowerPC 8xx for
which this driver is not used.

Signed-off-by: Sascha Hauer <s.hauer@pengutronix.de>
---
 drivers/net/fec.c |   94 -----------------------------------------------------
 1 files changed, 0 insertions(+), 94 deletions(-)

diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index 7e33c12..95785ef 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -72,8 +72,6 @@ static unsigned int fec_hw[] = {
 	(MCF_MBAR+0x30000),
 #elif defined(CONFIG_M532x)
 	(MCF_MBAR+0xfc030000),
-#else
-	&(((immap_t *)IMAP_ADDR)->im_cpm.cp_fec),
 #endif
 };
 
@@ -95,8 +93,6 @@ static unsigned char	fec_mac_default[] = {
 #define	FEC_FLASHMAC	(0xffe04000 + 4)
 #elif defined(CONFIG_MOD5272)
 #define FEC_FLASHMAC 	0xffc0406b
-#else
-#define	FEC_FLASHMAC	0
 #endif
 
 /* Forward declarations of some structures to support different PHYs
@@ -1760,96 +1756,6 @@ static void __inline__ fec_uncache(unsigned long addr)
 {
 }
 
-/* ------------------------------------------------------------------------- */
-
-
-#else
-
-/*
- *	Code specific to the MPC860T setup.
- */
-static void __inline__ fec_request_intrs(struct net_device *dev)
-{
-	volatile immap_t *immap;
-
-	immap = (immap_t *)IMAP_ADDR;	/* pointer to internal registers */
-
-	if (request_8xxirq(FEC_INTERRUPT, fec_enet_interrupt, 0, "fec", dev) != 0)
-		panic("Could not allocate FEC IRQ!");
-}
-
-static void __inline__ fec_get_mac(struct net_device *dev)
-{
-	bd_t *bd;
-
-	bd = (bd_t *)__res;
-	memcpy(dev->dev_addr, bd->bi_enetaddr, ETH_ALEN);
-}
-
-static void __inline__ fec_set_mii(struct net_device *dev, struct fec_enet_private *fep)
-{
-	extern uint _get_IMMR(void);
-	volatile immap_t *immap;
-	volatile fec_t *fecp;
-
-	fecp = fep->hwp;
-	immap = (immap_t *)IMAP_ADDR;	/* pointer to internal registers */
-
-	/* Configure all of port D for MII.
-	*/
-	immap->im_ioport.iop_pdpar = 0x1fff;
-
-	/* Bits moved from Rev. D onward.
-	*/
-	if ((_get_IMMR() & 0xffff) < 0x0501)
-		immap->im_ioport.iop_pddir = 0x1c58;	/* Pre rev. D */
-	else
-		immap->im_ioport.iop_pddir = 0x1fff;	/* Rev. D and later */
-
-	/* Set MII speed to 2.5 MHz
-	*/
-	fecp->fec_mii_speed = fep->phy_speed =
-		((bd->bi_busfreq * 1000000) / 2500000) & 0x7e;
-}
-
-static void __inline__ fec_enable_phy_intr(void)
-{
-	volatile fec_t *fecp;
-
-	fecp = fep->hwp;
-
-	/* Enable MII command finished interrupt
-	*/
-	fecp->fec_ivec = (FEC_INTERRUPT/2) << 29;
-}
-
-static void __inline__ fec_disable_phy_intr(void)
-{
-}
-
-static void __inline__ fec_phy_ack_intr(void)
-{
-}
-
-static void __inline__ fec_localhw_setup(void)
-{
-	volatile fec_t *fecp;
-
-	fecp = fep->hwp;
-	fecp->fec_r_hash = PKT_MAXBUF_SIZE;
-	/* Enable big endian and don't care about SDMA FC.
-	*/
-	fecp->fec_fun_code = 0x78000000;
-}
-
-static void __inline__ fec_uncache(unsigned long addr)
-{
-	pte_t *pte;
-	pte = va_to_pte(mem_addr);
-	pte_val(*pte) |= _PAGE_NO_CACHE;
-	flush_tlb_page(init_mm.mmap, mem_addr);
-}
-
 #endif
 
 /* ------------------------------------------------------------------------- */
-- 
1.5.6.5

