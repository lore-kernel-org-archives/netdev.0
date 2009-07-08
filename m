From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 4/8 net-next-2.6] cxgb3: AQ100X phy support update
Date: Tue, 07 Jul 2009 22:48:48 -0700
Message-ID: <20090708054848.11344.54063.stgit@speedy5>
References: <20090708054832.11344.82449.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:23915 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755919AbZGHFsu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2009 01:48:50 -0400
In-Reply-To: <20090708054832.11344.82449.stgit@speedy5>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>

Add missing SUPPORTED_TP flag.
Update FW version checking.
Do the full initialization even if the FW version is unknown,
it might help catching further issues.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/aq100x.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)


diff --git a/drivers/net/cxgb3/aq100x.c b/drivers/net/cxgb3/aq100x.c
index b1fd5bf..341b7ef 100644
--- a/drivers/net/cxgb3/aq100x.c
+++ b/drivers/net/cxgb3/aq100x.c
@@ -271,7 +271,8 @@ int t3_aq100x_phy_prep(struct cphy *phy, struct adapter *adapter, int phy_addr,
 
 	cphy_init(phy, adapter, phy_addr, &aq100x_ops, mdio_ops,
 		  SUPPORTED_1000baseT_Full | SUPPORTED_10000baseT_Full |
-		  SUPPORTED_Autoneg | SUPPORTED_AUI, "1000/10GBASE-T");
+		  SUPPORTED_TP | SUPPORTED_Autoneg | SUPPORTED_AUI,
+		  "1000/10GBASE-T");
 
 	/*
 	 * The PHY has been out of reset ever since the system powered up.  So
@@ -316,11 +317,9 @@ int t3_aq100x_phy_prep(struct cphy *phy, struct adapter *adapter, int phy_addr,
 
 	/* Firmware version check. */
 	t3_mdio_read(phy, MDIO_MMD_VEND1, AQ_FW_VERSION, &v);
-	if (v != 30) {
+	if (v != 101)
 		CH_WARN(adapter, "PHY%d: unsupported firmware %d\n",
 			phy_addr, v);
-		return 0; /* allow t3_prep_adapter to succeed */
-	}
 
 	/*
 	 * The PHY should start in really-low-power mode.  Prepare it for normal

