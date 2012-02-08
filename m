From: Danny Kukawka <danny.kukawka@bisect.de>
Subject: [PATCH 33/50] stmmac: use dev_hw_addr_random() instead of random_ether_addr()
Date: Wed,  8 Feb 2012 22:10:40 +0100
Message-ID: <1328735457-29986-34-git-send-email-danny.kukawka@bisect.de>
References: <1328735457-29986-1-git-send-email-danny.kukawka@bisect.de>
Cc: Danny Kukawka <dkukawka@suse.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wp188.webpack.hosteurope.de ([80.237.132.195]:34329 "EHLO
	wp188.webpack.hosteurope.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932285Ab2BHVWN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2012 16:22:13 -0500
In-Reply-To: <1328735457-29986-1-git-send-email-danny.kukawka@bisect.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use dev_hw_addr_random() instead of calling random_ether_addr()
to set addr_assign_type correctly to NET_ADDR_RANDOM.

Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>
---
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
index 96fa2da..e84bdb2 100644
--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
@@ -910,7 +910,7 @@ static void stmmac_check_ether_addr(struct stmmac_priv *priv)
 					     priv->dev->base_addr,
 					     priv->dev->dev_addr, 0);
 		if  (!is_valid_ether_addr(priv->dev->dev_addr))
-			random_ether_addr(priv->dev->dev_addr);
+			dev_hw_addr_random(priv->dev, priv->dev->dev_addr);
 	}
 	pr_warning("%s: device MAC address %pM\n", priv->dev->name,
 						   priv->dev->dev_addr);
-- 
1.7.7.3
