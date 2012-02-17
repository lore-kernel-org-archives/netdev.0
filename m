From: Danny Kukawka <danny.kukawka@bisect.de>
Subject: [PATCH v2 04/10] xilinx ll_temac: use eth_hw_addr_random() instead of random_ether_addr()
Date: Fri, 17 Feb 2012 16:43:25 +0100
Message-ID: <1329493411-25750-5-git-send-email-danny.kukawka@bisect.de>
References: <1329493411-25750-1-git-send-email-danny.kukawka@bisect.de>
Cc: Danny Kukawka <dkukawka@suse.de>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	Ricardo Ribalda Delgado <ricardo.ribalda@gmail.com>,
	Thomas Meyer <thomas@m3y3r.de>,
	Richard Cochran <richard.cochran@omicron.at>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1329493411-25750-1-git-send-email-danny.kukawka@bisect.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use eth_hw_addr_random() instead of calling random_ether_addr()
to set addr_assign_type correctly to NET_ADDR_RANDOM.

Reset the state to NET_ADDR_PERM as soon as the MAC get
changed via .ndo_set_mac_address.

v2: reworked to prevent using an extra variable

Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>
---
 drivers/net/ethernet/xilinx/ll_temac_main.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/xilinx/ll_temac_main.c b/drivers/net/ethernet/xilinx/ll_temac_main.c
index f21addb..c1f72e8 100644
--- a/drivers/net/ethernet/xilinx/ll_temac_main.c
+++ b/drivers/net/ethernet/xilinx/ll_temac_main.c
@@ -327,7 +327,9 @@ static int temac_set_mac_address(struct net_device *ndev, void *address)
 		memcpy(ndev->dev_addr, address, ETH_ALEN);
 
 	if (!is_valid_ether_addr(ndev->dev_addr))
-		random_ether_addr(ndev->dev_addr);
+		eth_hw_addr_random(ndev);
+	else 
+		dev->addr_assign_type &= ~NET_ADDR_RANDOM;
 
 	/* set up unicast MAC address filter set its mac address */
 	mutex_lock(&lp->indirect_mutex);
-- 
1.7.8.3
