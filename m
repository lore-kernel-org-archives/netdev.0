From: Danny Kukawka <danny.kukawka@bisect.de>
Subject: [PATCH v2 01/10] au1000_eth: use eth_hw_addr_random() instead of random_ether_addr()
Date: Fri, 17 Feb 2012 16:43:22 +0100
Message-ID: <1329493411-25750-2-git-send-email-danny.kukawka@bisect.de>
References: <1329493411-25750-1-git-send-email-danny.kukawka@bisect.de>
Cc: Danny Kukawka <dkukawka@suse.de>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jiri Pirko <jpirko@redhat.com>,
	Wan ZongShun <mcuos.com@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1329493411-25750-1-git-send-email-danny.kukawka@bisect.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use eth_hw_addr_random() instead of calling random_ether_addr()
to set addr_assign_type correctly to NET_ADDR_RANDOM.

v2: adapt to eth_hw_addr_random()

Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>
---
 drivers/net/ethernet/amd/au1000_eth.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/amd/au1000_eth.c b/drivers/net/ethernet/amd/au1000_eth.c
index 8b95dd3..8793daa 100644
--- a/drivers/net/ethernet/amd/au1000_eth.c
+++ b/drivers/net/ethernet/amd/au1000_eth.c
@@ -1130,9 +1130,6 @@ static int __devinit au1000_probe(struct platform_device *pdev)
 
 	au1000_setup_hw_rings(aup, aup->macdma);
 
-	/* set a random MAC now in case platform_data doesn't provide one */
-	random_ether_addr(dev->dev_addr);
-
 	writel(0, aup->enable);
 	aup->mac_enabled = 0;
 
@@ -1142,8 +1139,12 @@ static int __devinit au1000_probe(struct platform_device *pdev)
 					" PHY search on MAC0\n");
 		aup->phy1_search_mac0 = 1;
 	} else {
-		if (is_valid_ether_addr(pd->mac))
+		if (is_valid_ether_addr(pd->mac)) {
 			memcpy(dev->dev_addr, pd->mac, 6);
+		} else {
+			/*set a random MAC since no valid provided by platform_data*/
+			eth_hw_addr_random(dev);
+		}
 
 		aup->phy_static_config = pd->phy_static_config;
 		aup->phy_search_highest_addr = pd->phy_search_highest_addr;
-- 
1.7.8.3
