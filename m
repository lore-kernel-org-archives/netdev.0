From: Danny Kukawka <danny.kukawka@bisect.de>
Subject: [PATCH 4/8] bcm63xx_enet: use dev_set_mac_address() instead of bcm_enet_set_mac_address()
Date: Wed, 29 Feb 2012 16:42:52 +0100
Message-ID: <1330530176-24952-5-git-send-email-danny.kukawka@bisect.de>
References: <1330530176-24952-1-git-send-email-danny.kukawka@bisect.de>
Cc: Danny Kukawka <dkukawka@suse.de>,
	Florian Fainelli <florian@openwrt.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Jiri Kosina <jkosina@suse.cz>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1330530176-24952-1-git-send-email-danny.kukawka@bisect.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use dev_set_mac_address() instead of bcm_enet_set_mac_address() directly
to get validation checks for free.

Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>
---
 drivers/net/ethernet/broadcom/bcm63xx_enet.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bcm63xx_enet.c b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
index c7ca7ec..28184a8 100644
--- a/drivers/net/ethernet/broadcom/bcm63xx_enet.c
+++ b/drivers/net/ethernet/broadcom/bcm63xx_enet.c
@@ -858,7 +858,7 @@ static int bcm_enet_open(struct net_device *dev)
 
 	/* write device mac address */
 	memcpy(addr.sa_data, dev->dev_addr, ETH_ALEN);
-	bcm_enet_set_mac_address(dev, &addr);
+	dev_set_mac_address(dev, &addr);
 
 	/* allocate rx dma ring */
 	size = priv->rx_ring_size * sizeof(struct bcm_enet_desc);
-- 
1.7.8.3
