From: Amit Kucheria <amit.kucheria@canonical.com>
Subject: [PATCHv2 09/11] fec: Add LAN8700 phy support
Date: Tue,  2 Feb 2010 21:16:31 -0800
Message-ID: <a91f26ae7fc58ea0f88c82f1501e2905fc0f2ab1.1265173480.git.amit.kucheria@canonical.com>
References: <cover.1265173246.git.amit.kucheria@verdurent.com>
 <0511204199ab83aed2340e70a4639500c0528dab.1265173480.git.amit.kucheria@canonical.com>
 <9fa7a3c70c46a1f776c6520051481cff6525ef02.1265173480.git.amit.kucheria@canonical.com>
 <ccc89dd7a6035abf5a78680404a2b30b9e025353.1265173480.git.amit.kucheria@canonical.com>
 <ec63e5978fd5ac5d308ede5916e648ba925818eb.1265173480.git.amit.kucheria@canonical.com>
 <f10f79e7313ecdeeb59ab881795baedf2430c636.1265173480.git.amit.kucheria@canonical.com>
 <240f12ca87d7666f31263aabc620a9ec197cd8ff.1265173480.git.amit.kucheria@canonical.com>
 <752ae69adb57d4f73fa011ba380cea1b927b9c8b.1265173480.git.amit.kucheria@canonical.com>
 <e46b06510f7eb6ca51ea8b96335b2d32ec8bf6f8.1265173480.git.amit.kucheria@canonical.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux@arm.linux.org.uk,
	s.hauer@pengutronix.de, valentin.longchamp@epfl.ch,
	daniel@caiaq.de, grant.likely@secretlab.ca,
	Dinh.Nguyen@freescale.com, r.herring@freescale.com,
	bryan.wu@canonical.com
To: List Linux Kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <e46b06510f7eb6ca51ea8b96335b2d32ec8bf6f8.1265173480.git.amit.kucheria@canonical.com>
In-Reply-To: <cover.1265173480.git.amit.kucheria@canonical.com>
References: <cover.1265173480.git.amit.kucheria@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The i.MX51 babbage board has a FEC ethernet controller with this phy.

In the long term we should resurrect the phylib patches for fec.

Signed-off-by: Amit Kucheria <amit.kucheria@canonical.com>
Cc: David S. Miller <davem@davemloft.net>
Cc: netdev@vger.kernel.org
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
