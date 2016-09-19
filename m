From: John Crispin <john@phrozen.org>
Subject: [PATCH 1/4] net-next: dsa: fix duplicate invocation of set_addr()
Date: Mon, 19 Sep 2016 15:28:00 +0200
Message-ID: <1474291683-44167-2-git-send-email-john@phrozen.org>
References: <1474291683-44167-1-git-send-email-john@phrozen.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        John Crispin <john@phrozen.org>
To: "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:51009 "EHLO nbd.name"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S938792AbcISN2T (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 19 Sep 2016 09:28:19 -0400
In-Reply-To: <1474291683-44167-1-git-send-email-john@phrozen.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 83c0afaec7b730b ("net: dsa: Add new binding implementation")
has a duplicate invocation of the set_addr() operation callback. Remove one
of them.

Signed-off-by: John Crispin <john@phrozen.org>
---
 net/dsa/dsa2.c |    4 ----
 1 file changed, 4 deletions(-)

diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
index 8278385..cffc19e 100644
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@ -308,10 +308,6 @@ static int dsa_ds_apply(struct dsa_switch_tree *dst, struct dsa_switch *ds)
 	if (err < 0)
 		return err;
 
-	err = ds->ops->set_addr(ds, dst->master_netdev->dev_addr);
-	if (err < 0)
-		return err;
-
 	if (!ds->slave_mii_bus && ds->ops->phy_read) {
 		ds->slave_mii_bus = devm_mdiobus_alloc(ds->dev);
 		if (!ds->slave_mii_bus)
-- 
1.7.10.4
