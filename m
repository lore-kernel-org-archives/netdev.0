From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 4/8] r6040: fix typo on stats update in tx path
Date: Wed, 11 Apr 2012 19:18:39 +0200
Message-ID: <1334164723-9627-5-git-send-email-florian@openwrt.org>
References: <1334164723-9627-1-git-send-email-florian@openwrt.org>
Cc: netdev@vger.kernel.org, Florian Fainelli <florian@openwrt.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from zmc.proxad.net ([212.27.53.206]:45815 "EHLO zmc.proxad.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760779Ab2DKRUO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Apr 2012 13:20:14 -0400
In-Reply-To: <1334164723-9627-1-git-send-email-florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We are currently updating the rx fifo error counter in the tx path while
it should have been the tx fifo error counter, fix that.

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
 drivers/net/ethernet/rdc/r6040.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/rdc/r6040.c b/drivers/net/ethernet/rdc/r6040.c
index 9ffbf6e..db33573 100644
--- a/drivers/net/ethernet/rdc/r6040.c
+++ b/drivers/net/ethernet/rdc/r6040.c
@@ -605,7 +605,7 @@ static void r6040_tx(struct net_device *dev)
 		err = ioread16(ioaddr + MLSR);
 
 		if (err & 0x0200)
-			dev->stats.rx_fifo_errors++;
+			dev->stats.tx_fifo_errors++;
 		if (err & (0x2000 | 0x4000))
 			dev->stats.tx_carrier_errors++;
 
-- 
1.7.5.4
