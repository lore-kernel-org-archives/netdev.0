From: Pavel Machek <pavel@ucw.cz>
Subject: stmmac: add a warning when aliases are not present in device tree
Date: Mon, 23 Nov 2015 16:46:48 +0100
Message-ID: <20151123154648.GA16978@amd>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: trivial@kernel.org
To: peppe.cavallaro@st.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



If aliases are not present in device tree, stmmac_platform.c will
happily assign bus_id of 0 to all the ethernet interfaces, resulting
in hard to debug problems.

At least warn the user about the problem.

Signed-off-by: Pavel Machek <pavel@denx.de>

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
index f9b42f1..ee8aa26 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
@@ -161,8 +161,10 @@ static int stmmac_probe_config_dt(struct platform_device *pdev,
 		plat->max_speed = -1;
 
 	plat->bus_id = of_alias_get_id(np, "ethernet");
-	if (plat->bus_id < 0)
+	if (plat->bus_id < 0) {
+		dev_warn(&pdev->dev, "no aliases for ethernet; multiple ethernets will break\n");
 		plat->bus_id = 0;
+	}
 
 	/* Default to phy auto-detection */
 	plat->phy_addr = -1;

-- 
(english) http://www.livejournal.com/~pavelmachek
(cesky, pictures) http://atrey.karlin.mff.cuni.cz/~pavel/picture/horses/blog.html
