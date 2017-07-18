From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next] net: dsa: unexport dsa_is_port_initialized
Date: Tue, 18 Jul 2017 16:23:56 -0400
Message-ID: <20170718202356.7178-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The dsa_is_port_initialized helper is only used by dsa_switch_resume and
dsa_switch_suspend, if CONFIG_PM_SLEEP is enabled. Make it static to
dsa.c.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 include/net/dsa.h | 5 -----
 net/dsa/dsa.c     | 5 +++++
 2 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index 58969b9a090c..88da272d20d0 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -256,11 +256,6 @@ static inline bool dsa_is_normal_port(struct dsa_switch *ds, int p)
 	return !dsa_is_cpu_port(ds, p) && !dsa_is_dsa_port(ds, p);
 }
 
-static inline bool dsa_is_port_initialized(struct dsa_switch *ds, int p)
-{
-	return ds->enabled_port_mask & (1 << p) && ds->ports[p].netdev;
-}
-
 static inline u8 dsa_upstream_port(struct dsa_switch *ds)
 {
 	struct dsa_switch_tree *dst = ds->dst;
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 416ac4ef9ba9..a55e2e4087a4 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -220,6 +220,11 @@ static int dsa_switch_rcv(struct sk_buff *skb, struct net_device *dev,
 }
 
 #ifdef CONFIG_PM_SLEEP
+static bool dsa_is_port_initialized(struct dsa_switch *ds, int p)
+{
+	return ds->enabled_port_mask & (1 << p) && ds->ports[p].netdev;
+}
+
 int dsa_switch_suspend(struct dsa_switch *ds)
 {
 	int i, ret = 0;
-- 
2.13.3
