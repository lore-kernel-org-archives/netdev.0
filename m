From: Danny Kukawka <danny.kukawka@bisect.de>
Subject: [PATCH 16/50] pxa168_eth: use dev_hw_addr_random() instead of random_ether_addr()
Date: Wed,  8 Feb 2012 22:10:23 +0100
Message-ID: <1328735457-29986-17-git-send-email-danny.kukawka@bisect.de>
References: <1328735457-29986-1-git-send-email-danny.kukawka@bisect.de>
Cc: Danny Kukawka <dkukawka@suse.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Richard Cochran <richard.cochran@omicron.at>,
	Joe Perches <joe@perches.com>, Jon Mason <jdmason@kudzu.us>,
	Jiri Kosina <jkosina@suse.cz>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1328735457-29986-1-git-send-email-danny.kukawka@bisect.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use dev_hw_addr_random() instead of calling random_ether_addr()
to set addr_assign_type correctly to NET_ADDR_RANDOM.

Reset the state to NET_ADDR_PERM as soon as the MAC get
changed via .ndo_set_mac_address.

Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>
---
 drivers/net/ethernet/marvell/pxa168_eth.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/marvell/pxa168_eth.c b/drivers/net/ethernet/marvell/pxa168_eth.c
index 953ba58..76a5189 100644
--- a/drivers/net/ethernet/marvell/pxa168_eth.c
+++ b/drivers/net/ethernet/marvell/pxa168_eth.c
@@ -630,6 +630,8 @@ static int pxa168_eth_set_mac_address(struct net_device *dev, void *addr)
 		return -EINVAL;
 	memcpy(oldMac, dev->dev_addr, ETH_ALEN);
 	memcpy(dev->dev_addr, sa->sa_data, ETH_ALEN);
+	if (dev->addr_assign_type & NET_ADDR_RANDOM)
+		dev->addr_assign_type ^= NET_ADDR_RANDOM;
 	netif_addr_lock_bh(dev);
 	update_hash_table_mac_address(pep, oldMac, dev->dev_addr);
 	netif_addr_unlock_bh(dev);
@@ -1522,7 +1524,7 @@ static int pxa168_eth_probe(struct platform_device *pdev)
 	INIT_WORK(&pep->tx_timeout_task, pxa168_eth_tx_timeout_task);
 
 	printk(KERN_INFO "%s:Using random mac address\n", DRIVER_NAME);
-	random_ether_addr(dev->dev_addr);
+	dev_hw_addr_random(dev, dev->dev_addr);
 
 	pep->pd = pdev->dev.platform_data;
 	pep->rx_ring_size = NUM_RX_DESCS;
-- 
1.7.7.3
