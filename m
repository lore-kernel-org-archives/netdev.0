From: Amit Kucheria <amit.kucheria@canonical.com>
Subject: [PATCH 2/3] fec: Add LAN8700 phy support
Date: Fri,  5 Feb 2010 10:56:21 -0800
Message-ID: <2b1415552652de10697f5914f0de70dae1c672d4.1265396105.git.amit.kucheria@canonical.com>
References: <cover.1265396105.git.amit.kucheria@canonical.com>
 <39ec69d1e3af809dcf210f4757ca2385efb5f9bc.1265396105.git.amit.kucheria@canonical.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	s.hauer@pengutronix.de, gerg@uclinux.org,
	u.kleine-koenig@pengutronix.de, amit.kucheria@verdurent.com
To: List Linux Kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <39ec69d1e3af809dcf210f4757ca2385efb5f9bc.1265396105.git.amit.kucheria@canonical.com>
In-Reply-To: <cover.1265396105.git.amit.kucheria@canonical.com>
References: <cover.1265396105.git.amit.kucheria@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The i.MX51 babbage board has a FEC ethernet controller with this phy.

In the long term we should resurrect the phylib patches for fec.

Signed-off-by: Amit Kucheria <amit.kucheria@canonical.com>
Acked-by: Grant Likely <grant.likely@secretlab.ca>
---
 drivers/net/fec.c |   21 +++++++++++++++++++++
 1 files changed, 21 insertions(+), 0 deletions(-)

diff --git a/drivers/net/fec.c b/drivers/net/fec.c
index 9a8743d..5d0d332 100644
--- a/drivers/net/fec.c
+++ b/drivers/net/fec.c
@@ -1128,6 +1128,26 @@ static phy_info_t phy_info_dp83848= {
 	},
 };
 
+static phy_info_t phy_info_lan8700 = {
+	0x0007C0C,
+	"LAN8700",
+	(const phy_cmd_t []) { /* config */
+		{ mk_mii_read(MII_REG_CR), mii_parse_cr },
+		{ mk_mii_read(MII_REG_ANAR), mii_parse_anar },
+		{ mk_mii_end, }
+	},
+	(const phy_cmd_t []) { /* startup */
+		{ mk_mii_write(MII_REG_CR, 0x1200), NULL }, /* autonegotiate */
+		{ mk_mii_read(MII_REG_SR), mii_parse_sr },
+		{ mk_mii_end, }
+	},
+	(const phy_cmd_t []) { /* act_int */
+		{ mk_mii_end, }
+	},
+	(const phy_cmd_t []) { /* shutdown */
+		{ mk_mii_end, }
+	},
+};
 /* ------------------------------------------------------------------------- */
 
 static phy_info_t const * const phy_info[] = {
@@ -1137,6 +1157,7 @@ static phy_info_t const * const phy_info[] = {
 	&phy_info_am79c874,
 	&phy_info_ks8721bl,
 	&phy_info_dp83848,
+	&phy_info_lan8700,
 	NULL
 };
 
-- 
1.6.3.3
