From: Jonas Bonn <jonas@southpole.se>
Subject: [PATCH 6/7] ethoc: Clear command buffer after write
Date: Fri, 11 Jun 2010 14:47:39 +0200
Message-ID: <1276260460-14531-6-git-send-email-jonas@southpole.se>
References: <1276260460-14531-1-git-send-email-jonas@southpole.se>
Cc: Jonas Bonn <jonas@southpole.se>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.southpole.se ([193.12.106.18]:49429 "EHLO
	mail.southpole.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760228Ab0FKMrw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jun 2010 08:47:52 -0400
In-Reply-To: <1276260460-14531-1-git-send-email-jonas@southpole.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This matches what ethoc_mdio_read does and makes the functions
symmetric.

Signed-off-by: Jonas Bonn <jonas@southpole.se>
---
 drivers/net/ethoc.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethoc.c b/drivers/net/ethoc.c
index e5c2f5b..1681f08 100644
--- a/drivers/net/ethoc.c
+++ b/drivers/net/ethoc.c
@@ -613,8 +613,11 @@ static int ethoc_mdio_write(struct mii_bus *bus, int phy, int reg, u16 val)
 
 	while (time_before(jiffies, timeout)) {
 		u32 stat = ethoc_read(priv, MIISTATUS);
-		if (!(stat & MIISTATUS_BUSY))
+		if (!(stat & MIISTATUS_BUSY)) {
+			/* reset MII command register */
+			ethoc_write(priv, MIICOMMAND, 0);
 			return 0;
+		}
 
 		schedule();
 	}
-- 
1.7.0.4

