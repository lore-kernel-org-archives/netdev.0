From: Denis Kirjanov <dkirjanov@hera.kernel.org>
Subject: [PATCH net-next 2/3] ns83820: Add copper device settings
Date: Fri,  3 Sep 2010 20:05:40 +0000
Message-ID: <1283544341-18532-3-git-send-email-dkirjanov@hera.kernel.org>
References: <1283544341-18532-1-git-send-email-dkirjanov@hera.kernel.org>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:42791 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757346Ab0ICUFr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Sep 2010 16:05:47 -0400
In-Reply-To: <1283544341-18532-1-git-send-email-dkirjanov@hera.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Denis Kirjanov <dkirjanov@kernel.org>
---
 drivers/net/ns83820.c |   12 ++++++++++--
 1 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ns83820.c b/drivers/net/ns83820.c
index 3347125..712422a 100644
--- a/drivers/net/ns83820.c
+++ b/drivers/net/ns83820.c
@@ -1270,13 +1270,21 @@ static int ns83820_get_settings(struct net_device *ndev,
 
 	cmd->supported = SUPPORTED_Autoneg;
 
-	/* we have optical interface */
 	if (dev->CFG_cache & CFG_TBI_EN) {
+		/* we have optical interface */
 		cmd->supported |= SUPPORTED_1000baseT_Half |
 					SUPPORTED_1000baseT_Full |
 					SUPPORTED_FIBRE;
 		cmd->port       = PORT_FIBRE;
-	} /* TODO: else copper related  support */
+	} else {
+		/* we have copper */
+		cmd->supported |= SUPPORTED_10baseT_Half |
+			SUPPORTED_10baseT_Full | SUPPORTED_100baseT_Half |
+			SUPPORTED_100baseT_Full | SUPPORTED_1000baseT_Half |
+			SUPPORTED_1000baseT_Full |
+			SUPPORTED_MII;
+		cmd->port = PORT_MII;
+	}
 
 	cmd->duplex = fullduplex ? DUPLEX_FULL : DUPLEX_HALF;
 	switch (cfg / CFG_SPDSTS0 & 3) {
-- 
1.6.4.4

