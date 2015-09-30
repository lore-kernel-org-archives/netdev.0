From: Neil Armstrong <narmstrong@baylibre.com>
Subject: [RFC PATCH 1/3] net: dsa: Use devm_ prefixed allocations
Date: Wed, 30 Sep 2015 10:21:08 +0200
Message-ID: <560B9B74.3080905@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:38363 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754559AbbI3IVO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Sep 2015 04:21:14 -0400
Received: by wiclk2 with SMTP id lk2so49781729wic.1
        for <netdev@vger.kernel.org>; Wed, 30 Sep 2015 01:21:13 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To simplify and prevent memory leakage when unbinding, use
the devm_ memory allocation calls.

Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>
---
 net/dsa/dsa.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index c59fa5d..98f94c2 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -305,7 +305,7 @@ static int dsa_switch_setup_one(struct dsa_switch *ds, struct device *parent)
 	if (ret < 0)
 		goto out;

-	ds->slave_mii_bus = mdiobus_alloc();
+	ds->slave_mii_bus = devm_mdiobus_alloc(parent);
 	if (ds->slave_mii_bus == NULL) {
 		ret = -ENOMEM;
 		goto out;
@@ -400,7 +400,7 @@ dsa_switch_setup(struct dsa_switch_tree *dst, int index,
 	/*
 	 * Allocate and initialise switch state.
 	 */
-	ds = kzalloc(sizeof(*ds) + drv->priv_size, GFP_KERNEL);
+	ds = devm_kzalloc(parent, sizeof(*ds) + drv->priv_size, GFP_KERNEL);
 	if (ds == NULL)
 		return ERR_PTR(-ENOMEM);

@@ -883,7 +883,7 @@ static int dsa_probe(struct platform_device *pdev)
 		goto out;
 	}

-	dst = kzalloc(sizeof(*dst), GFP_KERNEL);
+	dst = devm_kzalloc(&pdev->dev, sizeof(*dst), GFP_KERNEL);
 	if (dst == NULL) {
 		dev_put(dev);
 		ret = -ENOMEM;
-- 
1.9.1
