From: Kyle Moffett <Kyle.D.Moffett@boeing.com>
Subject: [RFC PATCH 04/17] phy/icplus: Fix read_status/config_aneg error handling
Date: Thu, 20 Oct 2011 17:00:11 -0400
Message-ID: <1319144425-15547-5-git-send-email-Kyle.D.Moffett@boeing.com>
References: <1319144425-15547-1-git-send-email-Kyle.D.Moffett@boeing.com>
Cc: Kyle Moffett <Kyle.D.Moffett@boeing.com>,
	"David S. Miller" <davem@conan.davemloft.net>,
	Greg Dietsche <Gregory.Dietsche@cuw.edu>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1319144425-15547-1-git-send-email-Kyle.D.Moffett@boeing.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fixes the icplus PHY driver to propagate the return values of the
functions genphy_read_status() and genphy_config_aneg() instead of
ignoring them.

NOTE: Completely untested. Needs somebody with hardware to try it out.

Signed-off-by: Kyle Moffett <Kyle.D.Moffett@boeing.com>
---
 drivers/net/phy/icplus.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/phy/icplus.c b/drivers/net/phy/icplus.c
index d4cbc29..2969dac 100644
--- a/drivers/net/phy/icplus.c
+++ b/drivers/net/phy/icplus.c
@@ -115,19 +115,19 @@ static int ip1001_config_init(struct phy_device *phydev)
 static int ip175c_read_status(struct phy_device *phydev)
 {
 	if (phydev->addr == 4) /* WAN port */
-		genphy_read_status(phydev);
-	else
-		/* Don't need to read status for switch ports */
-		phydev->irq = PHY_IGNORE_INTERRUPT;
+		return genphy_read_status(phydev);
 
+	/* Don't need to read status for switch ports */
+	phydev->irq = PHY_IGNORE_INTERRUPT;
 	return 0;
 }
 
 static int ip175c_config_aneg(struct phy_device *phydev)
 {
 	if (phydev->addr == 4) /* WAN port */
-		genphy_config_aneg(phydev);
+		return genphy_config_aneg(phydev);
 
+	/* Don't need to do anything for switch ports */
 	return 0;
 }
 
-- 
1.7.2.5
