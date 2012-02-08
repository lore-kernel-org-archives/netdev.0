From: Danny Kukawka <danny.kukawka@bisect.de>
Subject: [PATCH 26/50] faraday: use dev_hw_addr_random() instead of random_ether_addr()
Date: Wed,  8 Feb 2012 22:10:33 +0100
Message-ID: <1328735457-29986-27-git-send-email-danny.kukawka@bisect.de>
References: <1328735457-29986-1-git-send-email-danny.kukawka@bisect.de>
Cc: Danny Kukawka <dkukawka@suse.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Po-Yu Chuang <ratbert@faraday-tech.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Thomas Faber <thfabba@gmx.de>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wp188.webpack.hosteurope.de ([80.237.132.195]:56665 "EHLO
	wp188.webpack.hosteurope.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750863Ab2BHVRA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2012 16:17:00 -0500
In-Reply-To: <1328735457-29986-1-git-send-email-danny.kukawka@bisect.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use dev_hw_addr_random() instead of calling random_ether_addr()
to set addr_assign_type correctly to NET_ADDR_RANDOM.

Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>
---
 drivers/net/ethernet/faraday/ftgmac100.c |    2 +-
 drivers/net/ethernet/faraday/ftmac100.c  |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index 47f85c3..4842659 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -1289,7 +1289,7 @@ static int ftgmac100_probe(struct platform_device *pdev)
 	netdev_info(netdev, "irq %d, mapped at %p\n", priv->irq, priv->base);
 
 	if (!is_valid_ether_addr(netdev->dev_addr)) {
-		random_ether_addr(netdev->dev_addr);
+		dev_hw_addr_random(netdev, netdev->dev_addr);
 		netdev_info(netdev, "generated random MAC address %pM\n",
 			    netdev->dev_addr);
 	}
diff --git a/drivers/net/ethernet/faraday/ftmac100.c b/drivers/net/ethernet/faraday/ftmac100.c
index bb336a0..1561010 100644
--- a/drivers/net/ethernet/faraday/ftmac100.c
+++ b/drivers/net/ethernet/faraday/ftmac100.c
@@ -1133,7 +1133,7 @@ static int ftmac100_probe(struct platform_device *pdev)
 	netdev_info(netdev, "irq %d, mapped at %p\n", priv->irq, priv->base);
 
 	if (!is_valid_ether_addr(netdev->dev_addr)) {
-		random_ether_addr(netdev->dev_addr);
+		dev_hw_addr_random(netdev, netdev->dev_addr);
 		netdev_info(netdev, "generated random MAC address %pM\n",
 			    netdev->dev_addr);
 	}
-- 
1.7.7.3
