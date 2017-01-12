From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 03/10] net: dsa: Suffix function manipulating
 device_node with _dn
Date: Wed, 11 Jan 2017 19:41:14 -0800
Message-ID: <20170112034121.27697-4-f.fainelli@gmail.com>
References: <20170112034121.27697-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>, Florian Fainelli <f.fainelli@gmail.com>,
 Jason Cooper <jason@lakedaemon.net>,
 Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
 gregkh@linuxfoundation.org, Russell King <linux@armlinux.org.uk>,
 open list <linux-kernel@vger.kernel.org>,
 Gregory Clement <gregory.clement@free-electrons.com>,
 "David S. Miller" <davem@davemloft.net>,
 "moderated list:ARM SUB-ARCHITECTURES" <linux-arm-kernel@lists.infradead.org>,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20170112034121.27697-1-f.fainelli@gmail.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Make it clear that these functions take a device_node structure pointer

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/dsa/dsa2.c | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
index 6e3675220fef..04ab62251fe3 100644
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@ -94,8 +94,8 @@ static bool dsa_port_is_cpu(struct dsa_port *port)
 	return !!of_parse_phandle(port->dn, "ethernet", 0);
 }
 
-static bool dsa_ds_find_port(struct dsa_switch *ds,
-			     struct device_node *port)
+static bool dsa_ds_find_port_dn(struct dsa_switch *ds,
+				struct device_node *port)
 {
 	u32 index;
 
@@ -105,8 +105,8 @@ static bool dsa_ds_find_port(struct dsa_switch *ds,
 	return false;
 }
 
-static struct dsa_switch *dsa_dst_find_port(struct dsa_switch_tree *dst,
-					    struct device_node *port)
+static struct dsa_switch *dsa_dst_find_port_dn(struct dsa_switch_tree *dst,
+					       struct device_node *port)
 {
 	struct dsa_switch *ds;
 	u32 index;
@@ -116,7 +116,7 @@ static struct dsa_switch *dsa_dst_find_port(struct dsa_switch_tree *dst,
 		if (!ds)
 			continue;
 
-		if (dsa_ds_find_port(ds, port))
+		if (dsa_ds_find_port_dn(ds, port))
 			return ds;
 	}
 
@@ -137,7 +137,7 @@ static int dsa_port_complete(struct dsa_switch_tree *dst,
 		if (!link)
 			break;
 
-		dst_ds = dsa_dst_find_port(dst, link);
+		dst_ds = dsa_dst_find_port_dn(dst, link);
 		of_node_put(link);
 
 		if (!dst_ds)
@@ -546,7 +546,7 @@ static int dsa_parse_ports_dn(struct device_node *ports, struct dsa_switch *ds)
 	return 0;
 }
 
-static int dsa_parse_member(struct device_node *np, u32 *tree, u32 *index)
+static int dsa_parse_member_dn(struct device_node *np, u32 *tree, u32 *index)
 {
 	int err;
 
@@ -592,7 +592,7 @@ static int _dsa_register_switch(struct dsa_switch *ds, struct device *dev)
 	u32 tree, index;
 	int i, err;
 
-	err = dsa_parse_member(np, &tree, &index);
+	err = dsa_parse_member_dn(np, &tree, &index);
 	if (err)
 		return err;
 
-- 
2.9.3
