From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: [PATCH 1/2] can: pch_can: fix sparse warning
Date: Wed, 27 Oct 2010 10:38:25 +0200
Message-ID: <1288168706-870-2-git-send-email-mkl@pengutronix.de>
References: <1288168706-870-1-git-send-email-mkl@pengutronix.de>
Cc: netdev@vger.kernel.org, Marc Kleine-Budde <mkl@pengutronix.de>,
	Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>
To: socketcan-core@lists.berlios.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:40424 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753581Ab0J0Iid (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Oct 2010 04:38:33 -0400
In-Reply-To: <1288168706-870-1-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes the following sparse warning:

drivers/net/can/pch_can.c:231:26: warning: incorrect type in argument 1 (different address spaces)
drivers/net/can/pch_can.c:231:26:    expected unsigned int [usertype] *addr
drivers/net/can/pch_can.c:231:26:    got unsigned int [noderef] <asn:2>*<noident>

Let pch_can_bit_{set,clear} first parameter be a void __iomem pointer.

Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
Cc: Tomoya MORINAGA <tomoya-linux@dsn.okisemi.com>
---
 drivers/net/can/pch_can.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/can/pch_can.c b/drivers/net/can/pch_can.c
index 55ec324..c63209f 100644
--- a/drivers/net/can/pch_can.c
+++ b/drivers/net/can/pch_can.c
@@ -213,12 +213,12 @@ static DEFINE_PCI_DEVICE_TABLE(pch_pci_tbl) = {
 };
 MODULE_DEVICE_TABLE(pci, pch_pci_tbl);
 
-static inline void pch_can_bit_set(u32 *addr, u32 mask)
+static inline void pch_can_bit_set(void __iomem *addr, u32 mask)
 {
 	iowrite32(ioread32(addr) | mask, addr);
 }
 
-static inline void pch_can_bit_clear(u32 *addr, u32 mask)
+static inline void pch_can_bit_clear(void __iomem *addr, u32 mask)
 {
 	iowrite32(ioread32(addr) & ~mask, addr);
 }
-- 
1.7.2.3

