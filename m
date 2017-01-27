From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 2/9] net: dsa: use ds->num_ports when possible
Date: Fri, 27 Jan 2017 15:29:37 -0500
Message-ID: <20170127202944.28598-3-vivien.didelot@savoirfairelinux.com>
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

The dsa_switch structure contains the number of ports. Use it where the
structure is valid instead of the DSA_MAX_PORTS value.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/dsa.c         | 16 ++++++++--------
 net/dsa/dsa2.c        | 12 ++++++------
 net/dsa/slave.c       |  2 +-
 net/dsa/tag_brcm.c    |  2 +-
 net/dsa/tag_dsa.c     |  2 +-
 net/dsa/tag_edsa.c    |  2 +-
 net/dsa/tag_trailer.c |  2 +-
 7 files changed, 19 insertions(+), 19 deletions(-)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index de3ffb421ee4..619e57a44d1d 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -145,7 +145,7 @@ static int dsa_cpu_dsa_setups(struct dsa_switch *ds, struct device *dev)
 	struct dsa_port *dport;
 	int ret, port;
 
-	for (port = 0; port < DSA_MAX_PORTS; port++) {
+	for (port = 0; port < ds->num_ports; port++) {
 		if (!(dsa_is_cpu_port(ds, port) || dsa_is_dsa_port(ds, port)))
 			continue;
 
@@ -218,7 +218,7 @@ static int dsa_switch_setup_one(struct dsa_switch *ds, struct device *parent)
 	/*
 	 * Validate supplied switch configuration.
 	 */
-	for (i = 0; i < DSA_MAX_PORTS; i++) {
+	for (i = 0; i < ds->num_ports; i++) {
 		char *name;
 
 		name = cd->port_names[i];
@@ -242,7 +242,7 @@ static int dsa_switch_setup_one(struct dsa_switch *ds, struct device *parent)
 		valid_name_found = true;
 	}
 
-	if (!valid_name_found && i == DSA_MAX_PORTS)
+	if (!valid_name_found && i == ds->num_ports)
 		return -EINVAL;
 
 	/* Make the built-in MII bus mask match the number of ports,
@@ -295,7 +295,7 @@ static int dsa_switch_setup_one(struct dsa_switch *ds, struct device *parent)
 	/*
 	 * Create network devices for physical switch ports.
 	 */
-	for (i = 0; i < DSA_MAX_PORTS; i++) {
+	for (i = 0; i < ds->num_ports; i++) {
 		ds->ports[i].dn = cd->port_dn[i];
 
 		if (!(ds->enabled_port_mask & (1 << i)))
@@ -377,7 +377,7 @@ static void dsa_switch_destroy(struct dsa_switch *ds)
 	int port;
 
 	/* Destroy network devices for physical switch ports. */
-	for (port = 0; port < DSA_MAX_PORTS; port++) {
+	for (port = 0; port < ds->num_ports; port++) {
 		if (!(ds->enabled_port_mask & (1 << port)))
 			continue;
 
@@ -388,7 +388,7 @@ static void dsa_switch_destroy(struct dsa_switch *ds)
 	}
 
 	/* Disable configuration of the CPU and DSA ports */
-	for (port = 0; port < DSA_MAX_PORTS; port++) {
+	for (port = 0; port < ds->num_ports; port++) {
 		if (!(dsa_is_cpu_port(ds, port) || dsa_is_dsa_port(ds, port)))
 			continue;
 		dsa_cpu_dsa_destroy(&ds->ports[port]);
@@ -408,7 +408,7 @@ int dsa_switch_suspend(struct dsa_switch *ds)
 	int i, ret = 0;
 
 	/* Suspend slave network devices */
-	for (i = 0; i < DSA_MAX_PORTS; i++) {
+	for (i = 0; i < ds->num_ports; i++) {
 		if (!dsa_is_port_initialized(ds, i))
 			continue;
 
@@ -435,7 +435,7 @@ int dsa_switch_resume(struct dsa_switch *ds)
 		return ret;
 
 	/* Resume slave network devices */
-	for (i = 0; i < DSA_MAX_PORTS; i++) {
+	for (i = 0; i < ds->num_ports; i++) {
 		if (!dsa_is_port_initialized(ds, i))
 			continue;
 
diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
index 4b3a44bec5c8..6e7b3e88b778 100644
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@ -98,7 +98,7 @@ static bool dsa_ds_find_port_dn(struct dsa_switch *ds,
 {
 	u32 index;
 
-	for (index = 0; index < DSA_MAX_PORTS; index++)
+	for (index = 0; index < ds->num_ports; index++)
 		if (ds->ports[index].dn == port)
 			return true;
 	return false;
@@ -159,7 +159,7 @@ static int dsa_ds_complete(struct dsa_switch_tree *dst, struct dsa_switch *ds)
 	u32 index;
 	int err;
 
-	for (index = 0; index < DSA_MAX_PORTS; index++) {
+	for (index = 0; index < ds->num_ports; index++) {
 		port = &ds->ports[index];
 		if (!dsa_port_is_valid(port))
 			continue;
@@ -312,7 +312,7 @@ static int dsa_ds_apply(struct dsa_switch_tree *dst, struct dsa_switch *ds)
 			return err;
 	}
 
-	for (index = 0; index < DSA_MAX_PORTS; index++) {
+	for (index = 0; index < ds->num_ports; index++) {
 		port = &ds->ports[index];
 		if (!dsa_port_is_valid(port))
 			continue;
@@ -344,7 +344,7 @@ static void dsa_ds_unapply(struct dsa_switch_tree *dst, struct dsa_switch *ds)
 	struct dsa_port *port;
 	u32 index;
 
-	for (index = 0; index < DSA_MAX_PORTS; index++) {
+	for (index = 0; index < ds->num_ports; index++) {
 		port = &ds->ports[index];
 		if (!dsa_port_is_valid(port))
 			continue;
@@ -475,7 +475,7 @@ static int dsa_ds_parse(struct dsa_switch_tree *dst, struct dsa_switch *ds)
 	u32 index;
 	int err;
 
-	for (index = 0; index < DSA_MAX_PORTS; index++) {
+	for (index = 0; index < ds->num_ports; index++) {
 		port = &ds->ports[index];
 		if (!dsa_port_is_valid(port))
 			continue;
@@ -529,7 +529,7 @@ static int dsa_parse_ports_dn(struct device_node *ports, struct dsa_switch *ds)
 		if (err)
 			return err;
 
-		if (reg >= DSA_MAX_PORTS)
+		if (reg >= ds->num_ports)
 			return -EINVAL;
 
 		ds->ports[reg].dn = port;
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index b8e58689a9a1..759824ba5545 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -404,7 +404,7 @@ static int dsa_fastest_ageing_time(struct dsa_switch *ds,
 {
 	int i;
 
-	for (i = 0; i < DSA_MAX_PORTS; ++i) {
+	for (i = 0; i < ds->num_ports; ++i) {
 		struct dsa_port *dp = &ds->ports[i];
 
 		if (dp && dp->ageing_time && dp->ageing_time < ageing_time)
diff --git a/net/dsa/tag_brcm.c b/net/dsa/tag_brcm.c
index cb5a2b7a0118..93e4458c02f9 100644
--- a/net/dsa/tag_brcm.c
+++ b/net/dsa/tag_brcm.c
@@ -128,7 +128,7 @@ static int brcm_tag_rcv(struct sk_buff *skb, struct net_device *dev,
 	source_port = brcm_tag[3] & BRCM_EG_PID_MASK;
 
 	/* Validate port against switch setup, either the port is totally */
-	if (source_port >= DSA_MAX_PORTS || !ds->ports[source_port].netdev)
+	if (source_port >= ds->num_ports || !ds->ports[source_port].netdev)
 		goto out_drop;
 
 	/* Remove Broadcom tag and update checksum */
diff --git a/net/dsa/tag_dsa.c b/net/dsa/tag_dsa.c
index bce79ffe342b..8fa4b1942671 100644
--- a/net/dsa/tag_dsa.c
+++ b/net/dsa/tag_dsa.c
@@ -114,7 +114,7 @@ static int dsa_rcv(struct sk_buff *skb, struct net_device *dev,
 	if (!ds)
 		goto out_drop;
 
-	if (source_port >= DSA_MAX_PORTS || !ds->ports[source_port].netdev)
+	if (source_port >= ds->num_ports || !ds->ports[source_port].netdev)
 		goto out_drop;
 
 	/*
diff --git a/net/dsa/tag_edsa.c b/net/dsa/tag_edsa.c
index 6c1720e88537..929de581a846 100644
--- a/net/dsa/tag_edsa.c
+++ b/net/dsa/tag_edsa.c
@@ -127,7 +127,7 @@ static int edsa_rcv(struct sk_buff *skb, struct net_device *dev,
 	if (!ds)
 		goto out_drop;
 
-	if (source_port >= DSA_MAX_PORTS || !ds->ports[source_port].netdev)
+	if (source_port >= ds->num_ports || !ds->ports[source_port].netdev)
 		goto out_drop;
 
 	/*
diff --git a/net/dsa/tag_trailer.c b/net/dsa/tag_trailer.c
index 271128a2dc64..d8e55a845d7f 100644
--- a/net/dsa/tag_trailer.c
+++ b/net/dsa/tag_trailer.c
@@ -82,7 +82,7 @@ static int trailer_rcv(struct sk_buff *skb, struct net_device *dev,
 		goto out_drop;
 
 	source_port = trailer[1] & 7;
-	if (source_port >= DSA_MAX_PORTS || !ds->ports[source_port].netdev)
+	if (source_port >= ds->num_ports || !ds->ports[source_port].netdev)
 		goto out_drop;
 
 	pskb_trim_rcsum(skb, skb->len - 4);
-- 
2.11.0
