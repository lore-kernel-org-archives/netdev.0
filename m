From: Danny Kukawka <danny.kukawka@bisect.de>
Subject: [PATCH 25/50] via-rhine: use dev_hw_addr_random() instead of random_ether_addr()
Date: Wed,  8 Feb 2012 22:10:32 +0100
Message-ID: <1328735457-29986-26-git-send-email-danny.kukawka@bisect.de>
References: <1328735457-29986-1-git-send-email-danny.kukawka@bisect.de>
Cc: Danny Kukawka <dkukawka@suse.de>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Roger Luethi <rl@hellgate.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1328735457-29986-1-git-send-email-danny.kukawka@bisect.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use dev_hw_addr_random() instead of calling random_ether_addr()
to set addr_assign_type correctly to NET_ADDR_RANDOM.

Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>
---
 drivers/net/ethernet/via/via-rhine.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
index 10b18eb..eda0711 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -984,7 +984,7 @@ static int __devinit rhine_init_one(struct pci_dev *pdev,
 	if (!is_valid_ether_addr(dev->dev_addr)) {
 		/* Report it and use a random ethernet address instead */
 		netdev_err(dev, "Invalid MAC address: %pM\n", dev->dev_addr);
-		random_ether_addr(dev->dev_addr);
+		dev_hw_addr_random(dev, dev->dev_addr);
 		netdev_info(dev, "Using random MAC address: %pM\n",
 			    dev->dev_addr);
 	}
-- 
1.7.7.3
