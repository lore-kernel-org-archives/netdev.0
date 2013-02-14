From: Nathan Hintz <nlhintz@hotmail.com>
Subject: [PATCH] bgmac: add read of interrupt mask after disabling interrupts
Date: Wed, 13 Feb 2013 21:14:10 -0800
Message-ID: <BLU0-SMTP798071F8F18DD115610285AC0F0@phx.gbl>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, hauke@hauke-m.de, zajec5@gmail.com,
	Nathan Hintz <nlhintz@hotmail.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from blu0-omc1-s4.blu0.hotmail.com ([65.55.116.15]:17309 "EHLO
	blu0-omc1-s4.blu0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751101Ab3BNFV0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Feb 2013 00:21:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The specs prescribe an immediate read of the interrupt mask after
disabling interrupts.  This patch updates the driver to match the
specs.

Signed-off-by: Nathan Hintz <nlhintz@hotmail.com>
---
 drivers/net/ethernet/broadcom/bgmac.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethernet/broadcom/bgmac.c
index 52d9a54..d341090 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -974,6 +974,7 @@ static void bgmac_chip_intrs_on(struct bgmac *bgmac)
 static void bgmac_chip_intrs_off(struct bgmac *bgmac)
 {
 	bgmac_write(bgmac, BGMAC_INT_MASK, 0);
+	bgmac_read(bgmac, BGMAC_INT_MASK);
 }
 
 /* http://bcm-v4.sipsolutions.net/mac-gbit/gmac/gmac_enable */
-- 
1.7.7.6
