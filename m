From: Colin King <colin.king@canonical.com>
Subject: [PATCH] net: dsa: mv88e6xxx: fix uninitialized error return
Date: Mon, 25 Apr 2016 23:11:22 +0100
Message-ID: <1461622282-30463-1-git-send-email-colin.king@canonical.com>
Cc: linux-kernel@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	Andrew Lunn <andrew@lunn.ch>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:45397 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965020AbcDYWL2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2016 18:11:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Colin Ian King <colin.king@canonical.com>

The error return err is not initialized and there is a possibility
that err is not assigned causing mv88e6xxx_port_bridge_join to
return a garbage error return status. Fix this by initializing err
to 0.

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/dsa/mv88e6xxx.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/dsa/mv88e6xxx.c b/drivers/net/dsa/mv88e6xxx.c
index 028f92f..98d3cfb 100644
--- a/drivers/net/dsa/mv88e6xxx.c
+++ b/drivers/net/dsa/mv88e6xxx.c
@@ -2207,7 +2207,7 @@ int mv88e6xxx_port_bridge_join(struct dsa_switch *ds, int port,
 			       struct net_device *bridge)
 {
 	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
-	int i, err;
+	int i, err = 0;
 
 	mutex_lock(&ps->smi_mutex);
 
-- 
2.7.4
