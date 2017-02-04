From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v5 1/4] net: dsa: Rename and export dev_to_net_device()
Date: Sat,  4 Feb 2017 13:02:42 -0800
Message-ID: <20170204210245.14812-2-f.fainelli@gmail.com>
References: <20170204210245.14812-1-f.fainelli@gmail.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        Jason Cooper <jason@lakedaemon.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory Clement <gregory.clement@free-electrons.com>,
        Russell King <linux@armlinux.org.uk>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        "David S. Miller" <davem@davemloft.net>,
        linux-arm-kernel@lists.infradead.org (moderated list:ARM/Marvell
        Dove/MV78xx0/Orion SOC support),
        linux-kernel@vger.kernel.org (open list)
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170204210245.14812-1-f.fainelli@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In preparation for using this function in net/dsa/dsa2.c, rename the function
to make its scope DSA specific, and export it.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 include/net/dsa.h | 1 +
 net/dsa/dsa.c     | 5 +++--
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index 2cb77e64d648..4327b0b03293 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -428,6 +428,7 @@ struct dsa_switch_driver {
 void register_switch_driver(struct dsa_switch_driver *type);
 void unregister_switch_driver(struct dsa_switch_driver *type);
 struct mii_bus *dsa_host_dev_to_mii_bus(struct device *dev);
+struct net_device *dsa_dev_to_net_device(struct device *dev);
 
 static inline bool dsa_uses_tagged_protocol(struct dsa_switch_tree *dst)
 {
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 619e57a44d1d..5a5f79bbda6f 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -486,7 +486,7 @@ struct mii_bus *dsa_host_dev_to_mii_bus(struct device *dev)
 }
 EXPORT_SYMBOL_GPL(dsa_host_dev_to_mii_bus);
 
-static struct net_device *dev_to_net_device(struct device *dev)
+struct net_device *dsa_dev_to_net_device(struct device *dev)
 {
 	struct device *d;
 
@@ -503,6 +503,7 @@ static struct net_device *dev_to_net_device(struct device *dev)
 
 	return NULL;
 }
+EXPORT_SYMBOL_GPL(dsa_dev_to_net_device);
 
 #ifdef CONFIG_OF
 static int dsa_of_setup_routing_table(struct dsa_platform_data *pd,
@@ -811,7 +812,7 @@ static int dsa_probe(struct platform_device *pdev)
 		dev = pd->of_netdev;
 		dev_hold(dev);
 	} else {
-		dev = dev_to_net_device(pd->netdev);
+		dev = dsa_dev_to_net_device(pd->netdev);
 	}
 	if (dev == NULL) {
 		ret = -EPROBE_DEFER;
-- 
2.9.3
