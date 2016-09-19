From: John Crispin <john@phrozen.org>
Subject: [PATCH 2/4] net-next: dsa: make the set_addr() operation optional
Date: Mon, 19 Sep 2016 15:28:01 +0200
Message-ID: <1474291683-44167-3-git-send-email-john@phrozen.org>
References: <1474291683-44167-1-git-send-email-john@phrozen.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        John Crispin <john@phrozen.org>
To: "David S. Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:51010 "EHLO nbd.name"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S938853AbcISN2Y (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 19 Sep 2016 09:28:24 -0400
In-Reply-To: <1474291683-44167-1-git-send-email-john@phrozen.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Only 1 of the 3 drivers currently has a set_addr() operation. Make the
set_addr() callback optional to reduce the amount of empty stubs inside
the drivers.

Signed-off-by: John Crispin <john@phrozen.org>
---
 net/dsa/dsa.c  |    8 +++++---
 net/dsa/dsa2.c |    8 +++++---
 2 files changed, 10 insertions(+), 6 deletions(-)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 66e31ac..a6902c1 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -378,9 +378,11 @@ static int dsa_switch_setup_one(struct dsa_switch *ds, struct device *parent)
 	if (ret < 0)
 		goto out;
 
-	ret = ops->set_addr(ds, dst->master_netdev->dev_addr);
-	if (ret < 0)
-		goto out;
+	if (ops->set_addr) {
+		ret = ops->set_addr(ds, dst->master_netdev->dev_addr);
+		if (ret < 0)
+			goto out;
+	}
 
 	if (!ds->slave_mii_bus && ops->phy_read) {
 		ds->slave_mii_bus = devm_mdiobus_alloc(parent);
diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
index cffc19e..f8a7d9a 100644
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@ -304,9 +304,11 @@ static int dsa_ds_apply(struct dsa_switch_tree *dst, struct dsa_switch *ds)
 	if (err < 0)
 		return err;
 
-	err = ds->ops->set_addr(ds, dst->master_netdev->dev_addr);
-	if (err < 0)
-		return err;
+	if (ds->ops->set_addr) {
+		err = ds->ops->set_addr(ds, dst->master_netdev->dev_addr);
+		if (err < 0)
+			return err;
+	}
 
 	if (!ds->slave_mii_bus && ds->ops->phy_read) {
 		ds->slave_mii_bus = devm_mdiobus_alloc(ds->dev);
-- 
1.7.10.4
