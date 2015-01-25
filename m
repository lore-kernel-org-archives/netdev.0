From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH ethtool 2/5] ethtool: Add missing Advertised speeds
Date: Sun, 25 Jan 2015 15:51:20 +0200
Message-ID: <1422193883-30504-3-git-send-email-amirv@mellanox.com>
References: <1422193883-30504-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Eyal Perry <eyalpe@mellanox.com>,
	Eyal Grossman <eyalgr@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:55297 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753260AbbAYNvm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 25 Jan 2015 08:51:42 -0500
In-Reply-To: <1422193883-30504-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eyal Grossman <eyalgr@mellanox.com>

Added the following missing advertised speed modes:
- ADVERTISED_10000baseT_Full
- ADVERTISED_56000baseKR4_Full
- ADVERTISED_56000baseCR4_Full
- ADVERTISED_56000baseSR4_Full
- ADVERTISED_56000baseLR4_Full
- ADVERTISED_10000baseKX4_Full

In order to reduce code duplication we added a macro to
ALL_ADVERTISED_FLAGS in line 88 ALL_ADVERTISED_MODES,
in addition the changed we made added speed that were
missing from ALL_ADVERTISED_MODES
(e.g. ADVERTISED_10000baseKX4_Full).

Added ADVERTISED_10000baseR_FEC to mode_defs.

Signed-off-by: Eyal Grossman <eyalgr@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 ethtool.c | 36 +++++++++++++++---------------------
 1 file changed, 15 insertions(+), 21 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index bf583f3..7b873d3 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -53,7 +53,9 @@
 	 ADVERTISED_100baseT_Full |		\
 	 ADVERTISED_1000baseT_Half |		\
 	 ADVERTISED_1000baseT_Full |		\
+	 ADVERTISED_1000baseKX_Full|		\
 	 ADVERTISED_2500baseX_Full |		\
+	 ADVERTISED_10000baseT_Full |		\
 	 ADVERTISED_10000baseKX4_Full |		\
 	 ADVERTISED_10000baseKR_Full |		\
 	 ADVERTISED_10000baseR_FEC |		\
@@ -62,36 +64,23 @@
 	 ADVERTISED_40000baseKR4_Full |		\
 	 ADVERTISED_40000baseCR4_Full |		\
 	 ADVERTISED_40000baseSR4_Full |		\
-	 ADVERTISED_40000baseLR4_Full)
+	 ADVERTISED_40000baseLR4_Full |		\
+	 ADVERTISED_56000baseKR4_Full |		\
+	 ADVERTISED_56000baseCR4_Full |		\
+	 ADVERTISED_56000baseSR4_Full |		\
+	 ADVERTISED_56000baseLR4_Full)
 
 #define ALL_ADVERTISED_FLAGS			\
-	(ADVERTISED_10baseT_Half |		\
-	 ADVERTISED_10baseT_Full |		\
-	 ADVERTISED_100baseT_Half |		\
-	 ADVERTISED_100baseT_Full |		\
-	 ADVERTISED_1000baseT_Half |		\
-	 ADVERTISED_1000baseT_Full |		\
-	 ADVERTISED_Autoneg |			\
+	(ADVERTISED_Autoneg |			\
 	 ADVERTISED_TP |			\
 	 ADVERTISED_AUI |			\
 	 ADVERTISED_MII |			\
 	 ADVERTISED_FIBRE |			\
 	 ADVERTISED_BNC |			\
-	 ADVERTISED_10000baseT_Full |		\
 	 ADVERTISED_Pause |			\
 	 ADVERTISED_Asym_Pause |		\
-	 ADVERTISED_2500baseX_Full |		\
 	 ADVERTISED_Backplane |			\
-	 ADVERTISED_1000baseKX_Full |		\
-	 ADVERTISED_10000baseKX4_Full |		\
-	 ADVERTISED_10000baseKR_Full |		\
-	 ADVERTISED_10000baseR_FEC |		\
-	 ADVERTISED_20000baseMLD2_Full |	\
-	 ADVERTISED_20000baseKR2_Full |		\
-	 ADVERTISED_40000baseKR4_Full |		\
-	 ADVERTISED_40000baseCR4_Full |		\
-	 ADVERTISED_40000baseSR4_Full |		\
-	 ADVERTISED_40000baseLR4_Full)
+	 ALL_ADVERTISED_MODES)
 
 #ifndef HAVE_NETIF_MSG
 enum {
@@ -527,15 +516,20 @@ dump_link_caps(const char *prefix, const char *an_prefix, u32 mask,
 		{ 1, ADVERTISED_1000baseT_Full,     "1000baseT/Full" },
 		{ 0, ADVERTISED_1000baseKX_Full,    "1000baseKX/Full" },
 		{ 0, ADVERTISED_2500baseX_Full,     "2500baseX/Full" },
-		{ 0, ADVERTISED_10000baseT_Full,    "10000baseT/Full" },
+		{ 1, ADVERTISED_10000baseT_Full,    "10000baseT/Full" },
 		{ 0, ADVERTISED_10000baseKX4_Full,  "10000baseKX4/Full" },
 		{ 0, ADVERTISED_10000baseKR_Full,   "10000baseKR/Full" },
+		{ 0, ADVERTISED_10000baseR_FEC,     "10000baseR/FEC" },
 		{ 0, ADVERTISED_20000baseMLD2_Full, "20000baseMLD2/Full" },
 		{ 0, ADVERTISED_20000baseKR2_Full,  "20000baseKR2/Full" },
 		{ 0, ADVERTISED_40000baseKR4_Full,  "40000baseKR4/Full" },
 		{ 0, ADVERTISED_40000baseCR4_Full,  "40000baseCR4/Full" },
 		{ 0, ADVERTISED_40000baseSR4_Full,  "40000baseSR4/Full" },
 		{ 0, ADVERTISED_40000baseLR4_Full,  "40000baseLR4/Full" },
+		{ 0, ADVERTISED_56000baseKR4_Full,  "56000baseKR4/Full" },
+		{ 0, ADVERTISED_56000baseCR4_Full,  "56000baseCR4/Full" },
+		{ 0, ADVERTISED_56000baseSR4_Full,  "56000baseSR4/Full" },
+		{ 0, ADVERTISED_56000baseLR4_Full,  "56000baseLR4/Full" },
 	};
 	int indent;
 	int did1, new_line_pend, i;
-- 
1.9.3
