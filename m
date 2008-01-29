From: Kalle Pokki <kalle.pokki@eke.com>
Subject: [PATCH] bfin_mac: Fix MDIO clock frequency
Date: Tue, 29 Jan 2008 14:27:26 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0801291421440.7503@pc-213-140-179-32.aina.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org, Bryan Wu <bryan.wu@analog.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.aina.net ([81.16.64.154]:33094 "EHLO smtp1.aina.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751642AbYA2MiX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jan 2008 07:38:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The clock divisor is set to all ones at reset.
---
 drivers/net/bfin_mac.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
index eb97175..c199633 100644
--- a/drivers/net/bfin_mac.c
+++ b/drivers/net/bfin_mac.c
@@ -425,7 +425,7 @@ static int mii_probe(struct net_device *dev)
 
 	/* MDC  = 2.5 MHz */
 	sysctl = bfin_read_EMAC_SYSCTL();
-	sysctl |= SET_MDCDIV(24);
+	sysctl = (sysctl & ~MDCDIV) | SET_MDCDIV(24);
 	bfin_write_EMAC_SYSCTL(sysctl);
 
 	/* search for connect PHY device */
-- 
1.4.4.2

