From: "Guo-Fu Tseng" <cooldavid@cooldavid.org>
Subject: [PATCH net-next-2.6 3/4] jme: Clear all modified GHC register flags
Date: Sat, 28 Feb 2009 11:58:16 +0800
Message-ID: <20090228035818.M14206@cooldavid.org>
References: <20080915165101.M68109@cooldavid.org> <48D27CDA.50501@pobox.com> <20081008215853.M53590@cooldavid.org>
Reply-To: cooldavid@cooldavid.org
Mime-Version: 1.0
Content-Type: text/plain;
	charset=big5
Cc: netdev@vger.kernel.org, Ethan <ethanhsiao@jmicron.com>
To: Jeff Garzik <jgarzik@pobox.com>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cooldavid.org ([220.133.139.86]:46801 "EHLO cooldavid.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754167AbZB1D7U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Feb 2009 22:59:20 -0500
In-Reply-To: <20081008215853.M53590@cooldavid.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Clear all modified GHC register flags.

Fixed-by: Ethan Hsiao <ethanhsiao@jmicron.com>
Signed-off-by: Guo-Fu Tseng <cooldavid@cooldavid.org>

diff --git a/drivers/net/jme.c b/drivers/net/jme.c
index f65a09c..47dd47f 100644
--- a/drivers/net/jme.c
+++ b/drivers/net/jme.c
@@ -429,10 +429,9 @@ jme_check_link(struct net_device *netdev, int testonly)
 
 		jme->phylink = phylink;
 
-		ghc = jme->reg_ghc & ~(GHC_SPEED_10M |
-					GHC_SPEED_100M |
-					GHC_SPEED_1000M |
-					GHC_DPX);
+		ghc = jme->reg_ghc & ~(GHC_SPEED | GHC_DPX |
+				GHC_TO_CLK_PCIE | GHC_TXMAC_CLK_PCIE |
+				GHC_TO_CLK_GPHY | GHC_TXMAC_CLK_GPHY);
 		switch (phylink & PHY_LINK_SPEED_MASK) {
 		case PHY_LINK_SPEED_10M:
 			ghc |= GHC_SPEED_10M |

