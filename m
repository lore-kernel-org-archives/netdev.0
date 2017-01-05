From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next] net: dsa: remove version string
Date: Thu,  5 Jan 2017 12:28:41 -0500
Message-ID: <20170105172841.16221-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The dsa_driver_version string is irrelevant and has not been bumped
since its introduction about 9 years ago. Kill it.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/dsa.c      | 5 -----
 net/dsa/dsa_priv.h | 1 -
 net/dsa/slave.c    | 1 -
 3 files changed, 7 deletions(-)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 89e66b623d73..3f85be0aae34 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -27,8 +27,6 @@
 #include <linux/gpio/consumer.h>
 #include "dsa_priv.h"
 
-char dsa_driver_version[] = "0.1";
-
 static struct sk_buff *dsa_slave_notag_xmit(struct sk_buff *skb,
 					    struct net_device *dev)
 {
@@ -926,9 +924,6 @@ static int dsa_probe(struct platform_device *pdev)
 	struct dsa_switch_tree *dst;
 	int ret;
 
-	pr_notice_once("Distributed Switch Architecture driver version %s\n",
-		       dsa_driver_version);
-
 	if (pdev->dev.of_node) {
 		ret = dsa_of_probe(&pdev->dev);
 		if (ret)
diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index 6cfd7388834e..63ae1484abae 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -49,7 +49,6 @@ struct dsa_slave_priv {
 };
 
 /* dsa.c */
-extern char dsa_driver_version[];
 int dsa_cpu_dsa_setup(struct dsa_switch *ds, struct device *dev,
 		      struct device_node *port_dn, int port);
 void dsa_cpu_dsa_destroy(struct device_node *port_dn);
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index ffd91969b830..5cd5b8137c08 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -673,7 +673,6 @@ static void dsa_slave_get_drvinfo(struct net_device *dev,
 				  struct ethtool_drvinfo *drvinfo)
 {
 	strlcpy(drvinfo->driver, "dsa", sizeof(drvinfo->driver));
-	strlcpy(drvinfo->version, dsa_driver_version, sizeof(drvinfo->version));
 	strlcpy(drvinfo->fw_version, "N/A", sizeof(drvinfo->fw_version));
 	strlcpy(drvinfo->bus_info, "platform", sizeof(drvinfo->bus_info));
 }
-- 
2.11.0
