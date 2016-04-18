From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next] net: dsa: remove tag_protocol from dsa_switch
Date: Mon, 18 Apr 2016 18:24:04 -0400
Message-ID: <1461018244-5371-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Having the tag protocol in dsa_switch_driver for setup time and in
dsa_switch_tree for runtime is enough. Remove dsa_switch's one.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 include/net/dsa.h | 5 -----
 net/dsa/dsa.c     | 5 ++---
 2 files changed, 2 insertions(+), 8 deletions(-)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index c4bc42b..2d280ab 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -136,11 +136,6 @@ struct dsa_switch {
 	void *priv;
 
 	/*
-	 * Tagging protocol understood by this switch
-	 */
-	enum dsa_tag_protocol	tag_protocol;
-
-	/*
 	 * Configuration data for this switch.
 	 */
 	struct dsa_chip_data	*pd;
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index efa612f..d61ceed 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -267,7 +267,7 @@ static int dsa_switch_setup_one(struct dsa_switch *ds, struct device *parent)
 	 * switch.
 	 */
 	if (dst->cpu_switch == index) {
-		switch (ds->tag_protocol) {
+		switch (drv->tag_protocol) {
 #ifdef CONFIG_NET_DSA_TAG_DSA
 		case DSA_TAG_PROTO_DSA:
 			dst->rcv = dsa_netdev_ops.rcv;
@@ -295,7 +295,7 @@ static int dsa_switch_setup_one(struct dsa_switch *ds, struct device *parent)
 			goto out;
 		}
 
-		dst->tag_protocol = ds->tag_protocol;
+		dst->tag_protocol = drv->tag_protocol;
 	}
 
 	/*
@@ -411,7 +411,6 @@ dsa_switch_setup(struct dsa_switch_tree *dst, int index,
 	ds->pd = pd;
 	ds->drv = drv;
 	ds->priv = priv;
-	ds->tag_protocol = drv->tag_protocol;
 	ds->master_dev = host_dev;
 
 	ret = dsa_switch_setup_one(ds, parent);
-- 
2.8.0
