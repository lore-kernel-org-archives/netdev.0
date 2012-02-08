From: Danny Kukawka <danny.kukawka@bisect.de>
Subject: [PATCH 28/50] forcedeth: use dev_hw_addr_random() instead of random_ether_addr()
Date: Wed,  8 Feb 2012 22:10:35 +0100
Message-ID: <1328735457-29986-29-git-send-email-danny.kukawka@bisect.de>
References: <1328735457-29986-1-git-send-email-danny.kukawka@bisect.de>
Cc: Danny Kukawka <dkukawka@suse.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	David Decotigny <david.decotigny@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jiri Pirko <jpirko@redhat.com>
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
 drivers/net/ethernet/nvidia/forcedeth.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
index 4c4e7f4..60176ad 100644
--- a/drivers/net/ethernet/nvidia/forcedeth.c
+++ b/drivers/net/ethernet/nvidia/forcedeth.c
@@ -3022,6 +3022,8 @@ static int nv_set_mac_address(struct net_device *dev, void *addr)
 
 	/* synchronized against open : rtnl_lock() held by caller */
 	memcpy(dev->dev_addr, macaddr->sa_data, ETH_ALEN);
+	if (dev->addr_assign_type & NET_ADDR_RANDOM)
+		dev->addr_assign_type ^= NET_ADDR_RANDOM;
 
 	if (netif_running(dev)) {
 		netif_tx_lock_bh(dev);
@@ -5741,7 +5743,7 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 		dev_err(&pci_dev->dev,
 			"Invalid MAC address detected: %pM - Please complain to your hardware vendor.\n",
 			dev->dev_addr);
-		random_ether_addr(dev->dev_addr);
+		dev_hw_addr_random(dev, dev->dev_addr);
 		dev_err(&pci_dev->dev,
 			"Using random MAC address: %pM\n", dev->dev_addr);
 	}
-- 
1.7.7.3
