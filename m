From: Andy Fleming <afleming@freescale.com>
Subject: [PATCH v2.6.29 2/2] gianfar: Fix potential soft reset race
Date: Tue,  3 Feb 2009 19:17:00 -0600
Message-ID: <1233710223-17808-2-git-send-email-afleming@freescale.com>
References: <1233710223-17808-1-git-send-email-afleming@freescale.com>
Cc: netdev@vger.kernel.org, Andy Fleming <afleming@freescale.com>
To: davem@davemloft.net, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:57441 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751358AbZBDBRW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Feb 2009 20:17:22 -0500
Received: from de01smr01.freescale.net (de01smr01.freescale.net [10.208.0.31])
	by az33egw02.freescale.net (8.14.3/az33egw02) with ESMTP id n141H4CR004693
	for <netdev@vger.kernel.org>; Tue, 3 Feb 2009 18:17:05 -0700 (MST)
Received: from ld0175-tx32.am.freescale.net (ld0175-tx32.am.freescale.net [10.82.19.125])
	by de01smr01.freescale.net (8.13.1/8.13.0) with ESMTP id n141H4O9007282
	for <netdev@vger.kernel.org>; Tue, 3 Feb 2009 19:17:04 -0600 (CST)
In-Reply-To: <1233710223-17808-1-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

SOFT_RESET must be asserted for at least 3 TX clocks in order for it to work
properly.  The syncs in the gfar_write() commands have been hiding this, but
we need to guarantee it.

Signed-off-by: Andy Fleming <afleming@freescale.com>
---
 drivers/net/gianfar.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 3f7eab4..acae2d8 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -351,6 +351,9 @@ static int gfar_probe(struct of_device *ofdev,
 	/* Reset MAC layer */
 	gfar_write(&priv->regs->maccfg1, MACCFG1_SOFT_RESET);
 
+	/* We need to delay at least 3 TX clocks */
+	udelay(2);
+
 	tempval = (MACCFG1_TX_FLOW | MACCFG1_RX_FLOW);
 	gfar_write(&priv->regs->maccfg1, tempval);
 
-- 
1.5.4.GIT

