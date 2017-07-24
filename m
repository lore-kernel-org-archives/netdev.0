From: <sean.wang@mediatek.com>
Subject: [PATCH] net: dsa: fixup fail to get tag in mtk_get_tag_protocol
Date: Mon, 24 Jul 2017 23:14:22 +0800
Message-ID: <77d2e1bb09314a27a08d02dec9ec62e217b2b9d6.1500908869.git.sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <linux-mediatek@lists.infradead.org>,
        Sean Wang <sean.wang@mediatek.com>
To: <davem@davemloft.net>, <andrew@lunn.ch>, <f.fainelli@gmail.com>,
        <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw02.mediatek.com ([210.61.82.184]:59091 "EHLO
        mailgw02.mediatek.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
        with ESMTP id S932427AbdGXPO3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 11:14:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sean Wang <sean.wang@mediatek.com>

dsa_is_cpu_port() checking ds->cpu_port_mask is not available in
ds->ops->get_tag_protocol

Since commit 14be36c2c96c ("net: dsa: Initialize all CPU and enabled
ports masks in dsa_ds_parse()") So force returning DSA_TAG_PROTO_MTK
inside mtk_get_tag_protocol call after that.

Cc: Florian Fainelli <f.fainelli@gmail.com>
Signed-off-by: Sean Wang <sean.wang@mediatek.com>
---
 drivers/net/dsa/mt7530.c | 10 +---------
 1 file changed, 1 insertion(+), 9 deletions(-)

diff --git a/drivers/net/dsa/mt7530.c b/drivers/net/dsa/mt7530.c
index 1e46418..c265e7e 100644
--- a/drivers/net/dsa/mt7530.c
+++ b/drivers/net/dsa/mt7530.c
@@ -892,15 +892,7 @@ mt7530_port_fdb_dump(struct dsa_switch *ds, int port,
 static enum dsa_tag_protocol
 mtk_get_tag_protocol(struct dsa_switch *ds)
 {
-	struct mt7530_priv *priv = ds->priv;
-
-	if (!dsa_is_cpu_port(ds, MT7530_CPU_PORT)) {
-		dev_warn(priv->dev,
-			 "port not matched with tagging CPU port\n");
-		return DSA_TAG_PROTO_NONE;
-	} else {
-		return DSA_TAG_PROTO_MTK;
-	}
+	return DSA_TAG_PROTO_MTK;
 }
 
 static int
-- 
2.7.4
