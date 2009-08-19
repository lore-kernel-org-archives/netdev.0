From: Petri Gynther <pgynther@google.com>
Subject: [PATCH] ibm_newemac: emac_close() needs to call netif_carrier_off()
Date: Wed, 19 Aug 2009 14:00:00 -0700 (PDT)
Message-ID: <20090819210000.D56AB254211@localhost>
Cc: netdev@vger.kernel.org
To: benh@kernel.crashing.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.33.17]:55178 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753155AbZHSVAU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2009 17:00:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When ibm_newemac netdev instance is shutdown with "ifconfig down",
the netdev interface does not go properly down. netif_carrier_ok()
keeps returning TRUE even after "ifconfig down".

The problem can be seen when ibm_newemac instances are slaves of
a bonding interface. The bonding interface code uses netif_carrier_ok()
to determine the link status of its slaves. When ibm_newemac slave is
shutdown with "ifconfig down", the bonding interface won't detect any
link status change because netif_carrier_ok() keeps returning TRUE.

Signed-off-by: Petri Gynther <pgynther@google.com>
---
 drivers/net/ibm_newemac/core.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ibm_newemac/core.c b/drivers/net/ibm_newemac/core.c
index beb8421..f0f8908 100644
--- a/drivers/net/ibm_newemac/core.c
+++ b/drivers/net/ibm_newemac/core.c
@@ -1305,6 +1305,8 @@ static int emac_close(struct net_device *ndev)
 
 	free_irq(dev->emac_irq, dev);
 
+	netif_carrier_off(ndev);
+
 	return 0;
 }
 
-- 
1.5.4.3

