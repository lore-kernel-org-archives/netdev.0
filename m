From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH 11/25] net: mvpp2: Improve 27 size determinations
Date: Mon, 17 Apr 2017 17:21:12 +0200
Message-ID: <c5d8256f-bc13-b424-d5ff-9e1425e25eb8@users.sourceforge.net>
References: <d6f26bba-c678-5b66-4f5d-85f56d895190@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Jarod Wilson <jarod@redhat.com>,
        Jisheng Zhang <jszhang@marvell.com>,
        Mirko Lindner <mlindner@marvell.com>,
        Philippe Reynes <tremyfr@gmail.com>,
        Russell King <rmk+kernel@armlinux.org.uk>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <d6f26bba-c678-5b66-4f5d-85f56d895190@users.sourceforge.net>
Content-Language: en-GB
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Mon, 17 Apr 2017 10:30:29 +0200

Replace the specification of data structures by references to
a local variable as the parameter for the operator "sizeof"
to make the corresponding size determination a bit safer.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/ethernet/marvell/mvpp2.c | 54 ++++++++++++++++++------------------
 1 file changed, 27 insertions(+), 27 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index abf084b43af7..61fd87d0a4ec 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -1689,7 +1689,7 @@ static void mvpp2_prs_mac_drop_all_set(struct mvpp2 *priv, int port, bool add)
 		mvpp2_prs_hw_read(priv, &pe);
 	} else {
 		/* Entry doesn't exist - create new */
-		memset(&pe, 0, sizeof(struct mvpp2_prs_entry));
+		memset(&pe, 0, sizeof(pe));
 		mvpp2_prs_tcam_lu_set(&pe, MVPP2_PRS_LU_MAC);
 		pe.index = MVPP2_PE_DROP_ALL;
 
@@ -1726,7 +1726,7 @@ static void mvpp2_prs_mac_promisc_set(struct mvpp2 *priv, int port, bool add)
 		mvpp2_prs_hw_read(priv, &pe);
 	} else {
 		/* Entry doesn't exist - create new */
-		memset(&pe, 0, sizeof(struct mvpp2_prs_entry));
+		memset(&pe, 0, sizeof(pe));
 		mvpp2_prs_tcam_lu_set(&pe, MVPP2_PRS_LU_MAC);
 		pe.index = MVPP2_PE_MAC_PROMISCUOUS;
 
@@ -1772,7 +1772,7 @@ static void mvpp2_prs_mac_multi_set(struct mvpp2 *priv, int port, int index,
 		mvpp2_prs_hw_read(priv, &pe);
 	} else {
 		/* Entry doesn't exist - create new */
-		memset(&pe, 0, sizeof(struct mvpp2_prs_entry));
+		memset(&pe, 0, sizeof(pe));
 		mvpp2_prs_tcam_lu_set(&pe, MVPP2_PRS_LU_MAC);
 		pe.index = index;
 
@@ -1824,7 +1824,7 @@ static void mvpp2_prs_dsa_tag_set(struct mvpp2 *priv, int port, bool add,
 		mvpp2_prs_hw_read(priv, &pe);
 	} else {
 		/* Entry doesn't exist - create new */
-		memset(&pe, 0, sizeof(struct mvpp2_prs_entry));
+		memset(&pe, 0, sizeof(pe));
 		mvpp2_prs_tcam_lu_set(&pe, MVPP2_PRS_LU_DSA);
 		pe.index = tid;
 
@@ -1887,7 +1887,7 @@ static void mvpp2_prs_dsa_tag_ethertype_set(struct mvpp2 *priv, int port,
 		mvpp2_prs_hw_read(priv, &pe);
 	} else {
 		/* Entry doesn't exist - create new */
-		memset(&pe, 0, sizeof(struct mvpp2_prs_entry));
+		memset(&pe, 0, sizeof(pe));
 		mvpp2_prs_tcam_lu_set(&pe, MVPP2_PRS_LU_DSA);
 		pe.index = tid;
 
@@ -2212,7 +2212,7 @@ static int mvpp2_prs_ip4_proto(struct mvpp2 *priv, unsigned short proto,
 	if (tid < 0)
 		return tid;
 
-	memset(&pe, 0, sizeof(struct mvpp2_prs_entry));
+	memset(&pe, 0, sizeof(pe));
 	mvpp2_prs_tcam_lu_set(&pe, MVPP2_PRS_LU_IP4);
 	pe.index = tid;
 
@@ -2270,7 +2270,7 @@ static int mvpp2_prs_ip4_cast(struct mvpp2 *priv, unsigned short l3_cast)
 	if (tid < 0)
 		return tid;
 
-	memset(&pe, 0, sizeof(struct mvpp2_prs_entry));
+	memset(&pe, 0, sizeof(pe));
 	mvpp2_prs_tcam_lu_set(&pe, MVPP2_PRS_LU_IP4);
 	pe.index = tid;
 
@@ -2326,7 +2326,7 @@ static int mvpp2_prs_ip6_proto(struct mvpp2 *priv, unsigned short proto,
 	if (tid < 0)
 		return tid;
 
-	memset(&pe, 0, sizeof(struct mvpp2_prs_entry));
+	memset(&pe, 0, sizeof(pe));
 	mvpp2_prs_tcam_lu_set(&pe, MVPP2_PRS_LU_IP6);
 	pe.index = tid;
 
@@ -2365,7 +2365,7 @@ static int mvpp2_prs_ip6_cast(struct mvpp2 *priv, unsigned short l3_cast)
 	if (tid < 0)
 		return tid;
 
-	memset(&pe, 0, sizeof(struct mvpp2_prs_entry));
+	memset(&pe, 0, sizeof(pe));
 	mvpp2_prs_tcam_lu_set(&pe, MVPP2_PRS_LU_IP6);
 	pe.index = tid;
 
@@ -2425,7 +2425,7 @@ static void mvpp2_prs_def_flow_init(struct mvpp2 *priv)
 	int port;
 
 	for (port = 0; port < MVPP2_MAX_PORTS; port++) {
-		memset(&pe, 0, sizeof(struct mvpp2_prs_entry));
+		memset(&pe, 0, sizeof(pe));
 		mvpp2_prs_tcam_lu_set(&pe, MVPP2_PRS_LU_FLOWS);
 		pe.index = MVPP2_PE_FIRST_DEFAULT_FLOW - port;
 
@@ -2447,7 +2447,7 @@ static void mvpp2_prs_mh_init(struct mvpp2 *priv)
 {
 	struct mvpp2_prs_entry pe;
 
-	memset(&pe, 0, sizeof(struct mvpp2_prs_entry));
+	memset(&pe, 0, sizeof(pe));
 
 	pe.index = MVPP2_PE_MH_DEFAULT;
 	mvpp2_prs_tcam_lu_set(&pe, MVPP2_PRS_LU_MH);
@@ -2470,7 +2470,7 @@ static void mvpp2_prs_mac_init(struct mvpp2 *priv)
 {
 	struct mvpp2_prs_entry pe;
 
-	memset(&pe, 0, sizeof(struct mvpp2_prs_entry));
+	memset(&pe, 0, sizeof(pe));
 
 	/* Non-promiscuous mode for all ports - DROP unknown packets */
 	pe.index = MVPP2_PE_MAC_NON_PROMISCUOUS;
@@ -2531,7 +2531,7 @@ static void mvpp2_prs_dsa_init(struct mvpp2 *priv)
 					MVPP2_PRS_TAGGED, MVPP2_PRS_DSA);
 
 	/* Set default entry, in case DSA or EDSA tag not found */
-	memset(&pe, 0, sizeof(struct mvpp2_prs_entry));
+	memset(&pe, 0, sizeof(pe));
 	mvpp2_prs_tcam_lu_set(&pe, MVPP2_PRS_LU_DSA);
 	pe.index = MVPP2_PE_DSA_DEFAULT;
 	mvpp2_prs_sram_next_lu_set(&pe, MVPP2_PRS_LU_VLAN);
@@ -2561,7 +2561,7 @@ static int mvpp2_prs_etype_init(struct mvpp2 *priv)
 	if (tid < 0)
 		return tid;
 
-	memset(&pe, 0, sizeof(struct mvpp2_prs_entry));
+	memset(&pe, 0, sizeof(pe));
 	mvpp2_prs_tcam_lu_set(&pe, MVPP2_PRS_LU_L2);
 	pe.index = tid;
 
@@ -2587,7 +2587,7 @@ static int mvpp2_prs_etype_init(struct mvpp2 *priv)
 	if (tid < 0)
 		return tid;
 
-	memset(&pe, 0, sizeof(struct mvpp2_prs_entry));
+	memset(&pe, 0, sizeof(pe));
 	mvpp2_prs_tcam_lu_set(&pe, MVPP2_PRS_LU_L2);
 	pe.index = tid;
 
@@ -2617,7 +2617,7 @@ static int mvpp2_prs_etype_init(struct mvpp2 *priv)
 	if (tid < 0)
 		return tid;
 
-	memset(&pe, 0, sizeof(struct mvpp2_prs_entry));
+	memset(&pe, 0, sizeof(pe));
 	mvpp2_prs_tcam_lu_set(&pe, MVPP2_PRS_LU_L2);
 	pe.index = tid;
 
@@ -2651,7 +2651,7 @@ static int mvpp2_prs_etype_init(struct mvpp2 *priv)
 	if (tid < 0)
 		return tid;
 
-	memset(&pe, 0, sizeof(struct mvpp2_prs_entry));
+	memset(&pe, 0, sizeof(pe));
 	mvpp2_prs_tcam_lu_set(&pe, MVPP2_PRS_LU_L2);
 	pe.index = tid;
 
@@ -2716,7 +2716,7 @@ static int mvpp2_prs_etype_init(struct mvpp2 *priv)
 	if (tid < 0)
 		return tid;
 
-	memset(&pe, 0, sizeof(struct mvpp2_prs_entry));
+	memset(&pe, 0, sizeof(pe));
 	mvpp2_prs_tcam_lu_set(&pe, MVPP2_PRS_LU_L2);
 	pe.index = tid;
 
@@ -2813,7 +2813,7 @@ static int mvpp2_prs_vlan_init(struct platform_device *pdev, struct mvpp2 *priv)
 		return err;
 
 	/* Set default double vlan entry */
-	memset(&pe, 0, sizeof(struct mvpp2_prs_entry));
+	memset(&pe, 0, sizeof(pe));
 	mvpp2_prs_tcam_lu_set(&pe, MVPP2_PRS_LU_VLAN);
 	pe.index = MVPP2_PE_VLAN_DBL;
 
@@ -2833,7 +2833,7 @@ static int mvpp2_prs_vlan_init(struct platform_device *pdev, struct mvpp2 *priv)
 	mvpp2_prs_hw_write(priv, &pe);
 
 	/* Set default vlan none entry */
-	memset(&pe, 0, sizeof(struct mvpp2_prs_entry));
+	memset(&pe, 0, sizeof(pe));
 	mvpp2_prs_tcam_lu_set(&pe, MVPP2_PRS_LU_VLAN);
 	pe.index = MVPP2_PE_VLAN_NONE;
 
@@ -2863,7 +2863,7 @@ static int mvpp2_prs_pppoe_init(struct mvpp2 *priv)
 	if (tid < 0)
 		return tid;
 
-	memset(&pe, 0, sizeof(struct mvpp2_prs_entry));
+	memset(&pe, 0, sizeof(pe));
 	mvpp2_prs_tcam_lu_set(&pe, MVPP2_PRS_LU_PPPOE);
 	pe.index = tid;
 
@@ -2913,7 +2913,7 @@ static int mvpp2_prs_pppoe_init(struct mvpp2 *priv)
 	if (tid < 0)
 		return tid;
 
-	memset(&pe, 0, sizeof(struct mvpp2_prs_entry));
+	memset(&pe, 0, sizeof(pe));
 	mvpp2_prs_tcam_lu_set(&pe, MVPP2_PRS_LU_PPPOE);
 	pe.index = tid;
 
@@ -2940,7 +2940,7 @@ static int mvpp2_prs_pppoe_init(struct mvpp2 *priv)
 	if (tid < 0)
 		return tid;
 
-	memset(&pe, 0, sizeof(struct mvpp2_prs_entry));
+	memset(&pe, 0, sizeof(pe));
 	mvpp2_prs_tcam_lu_set(&pe, MVPP2_PRS_LU_PPPOE);
 	pe.index = tid;
 
@@ -2998,7 +2998,7 @@ static int mvpp2_prs_ip4_init(struct mvpp2 *priv)
 		return err;
 
 	/* Default IPv4 entry for unknown protocols */
-	memset(&pe, 0, sizeof(struct mvpp2_prs_entry));
+	memset(&pe, 0, sizeof(pe));
 	mvpp2_prs_tcam_lu_set(&pe, MVPP2_PRS_LU_IP4);
 	pe.index = MVPP2_PE_IP4_PROTO_UN;
 
@@ -3023,7 +3023,7 @@ static int mvpp2_prs_ip4_init(struct mvpp2 *priv)
 	mvpp2_prs_hw_write(priv, &pe);
 
 	/* Default IPv4 entry for unicast address */
-	memset(&pe, 0, sizeof(struct mvpp2_prs_entry));
+	memset(&pe, 0, sizeof(pe));
 	mvpp2_prs_tcam_lu_set(&pe, MVPP2_PRS_LU_IP4);
 	pe.index = MVPP2_PE_IP4_ADDR_UN;
 
@@ -3091,7 +3091,7 @@ static int mvpp2_prs_ip6_init(struct mvpp2 *priv)
 	if (tid < 0)
 		return tid;
 
-	memset(&pe, 0, sizeof(struct mvpp2_prs_entry));
+	memset(&pe, 0, sizeof(pe));
 	mvpp2_prs_tcam_lu_set(&pe, MVPP2_PRS_LU_IP6);
 	pe.index = tid;
 
@@ -3112,7 +3112,7 @@ static int mvpp2_prs_ip6_init(struct mvpp2 *priv)
 	mvpp2_prs_hw_write(priv, &pe);
 
 	/* Default IPv6 entry for unknown protocols */
-	memset(&pe, 0, sizeof(struct mvpp2_prs_entry));
+	memset(&pe, 0, sizeof(pe));
 	mvpp2_prs_tcam_lu_set(&pe, MVPP2_PRS_LU_IP6);
 	pe.index = MVPP2_PE_IP6_PROTO_UN;
 
-- 
2.12.2
