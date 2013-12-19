From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 2/2] sh_eth: do not reset PHY needlessly
Date: Fri, 20 Dec 2013 01:41:12 +0300
Message-ID: <201312200141.12586.sergei.shtylyov@cogentembedded.com>
References: <201312200138.09307.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <201312200138.09307.sergei.shtylyov@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There's no need anymore to call phy_init_hw() to reset/resume the PHY from the
driver, as the call chain in phylib already has reached it, and so reset/resumed
the PHY (even resuming it twice). This duplicate reset is not only  needless, it
e.g. clears the PHY's interrupt enables just setup by phylib and so prevents the
expected IRQs from the PHY.

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
 drivers/net/ethernet/renesas/sh_eth.c |    5 -----
 1 file changed, 5 deletions(-)

Index: net-next/drivers/net/ethernet/renesas/sh_eth.c
===================================================================
--- net-next.orig/drivers/net/ethernet/renesas/sh_eth.c
+++ net-next/drivers/net/ethernet/renesas/sh_eth.c
@@ -1703,11 +1703,6 @@ static int sh_eth_phy_start(struct net_d
 	if (ret)
 		return ret;
 
-	/* reset phy - this also wakes it from PDOWN */
-	ret = phy_init_hw(mdp->phydev);
-	if (ret)
-		return ret;
-
 	phy_start(mdp->phydev);
 
 	return 0;
