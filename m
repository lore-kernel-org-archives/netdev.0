From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 3/9] net: dsa: add ds and index to dsa_port
Date: Fri, 27 Jan 2017 15:29:38 -0500
Message-ID: <20170127202944.28598-4-vivien.didelot@savoirfairelinux.com>
References: <20170127202944.28598-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>, John Crispin <john@phrozen.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170127202944.28598-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add the physical switch instance and port index a DSA port belongs to to
the dsa_port structure.

That can be used later to retrieve information about a physical port
when configuring a switch fabric, or lighten up struct dsa_slave_priv.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 include/net/dsa.h | 2 ++
 net/dsa/dsa2.c    | 6 ++++++
 2 files changed, 8 insertions(+)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index 24e1d935ae68..6bd1f8b05dbd 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -140,6 +140,8 @@ struct dsa_switch_tree {
 };
 
 struct dsa_port {
+	struct dsa_switch	*ds;
+	unsigned int		index;
 	struct net_device	*netdev;
 	struct device_node	*dn;
 	unsigned int		ageing_time;
diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
index 6e7b3e88b778..9f8cc26be9ea 100644
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@ -670,6 +670,7 @@ struct dsa_switch *dsa_switch_alloc(struct device *dev, size_t n)
 {
 	size_t size = sizeof(struct dsa_switch) + n * sizeof(struct dsa_port);
 	struct dsa_switch *ds;
+	int i;
 
 	ds = devm_kzalloc(dev, size, GFP_KERNEL);
 	if (!ds)
@@ -678,6 +679,11 @@ struct dsa_switch *dsa_switch_alloc(struct device *dev, size_t n)
 	ds->dev = dev;
 	ds->num_ports = n;
 
+	for (i = 0; i < ds->num_ports; ++i) {
+		ds->ports[i].index = i;
+		ds->ports[i].ds = ds;
+	}
+
 	return ds;
 }
 EXPORT_SYMBOL_GPL(dsa_switch_alloc);
-- 
2.11.0
