From: Nageswari Srinivasan <nageswari@ti.com>
Subject: [PATCH] TI DaVinci EMAC: Fix MDIO bus frequency configuration
Date: Wed, 16 Dec 2009 14:58:59 +0530
Message-ID: <1260955739-30348-1-git-send-email-nageswari@ti.com>
Cc: anantgole@ti.com, davinci-linux-open-source@linux.davincidsp.com,
	davem@davemloft.net, Nageswari Srinivasan <nageswari@ti.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:42269 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753798AbZLPJ3M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Dec 2009 04:29:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There was a typo in "if condition" checking for validity of MDIO
bus frequency passed as part of platform data. Bitwise AND was
being used instead of a Logical AND.

Tested on: DM6467 EVM

Signed-off-by: Nageswari Srinivasan <nageswari@ti.com>
Acked-by: Anant Gole <anantgole@ti.com>
---
 drivers/net/davinci_emac.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/davinci_emac.c b/drivers/net/davinci_emac.c
index 65a2d0b..8f8c696 100644
--- a/drivers/net/davinci_emac.c
+++ b/drivers/net/davinci_emac.c
@@ -2276,7 +2276,7 @@ static int emac_mii_reset(struct mii_bus *bus)
 	unsigned int clk_div;
 	int mdio_bus_freq = emac_bus_frequency;
 
-	if (mdio_max_freq & mdio_bus_freq)
+	if (mdio_max_freq && mdio_bus_freq)
 		clk_div = ((mdio_bus_freq / mdio_max_freq) - 1);
 	else
 		clk_div = 0xFF;
-- 
1.6.2.4

