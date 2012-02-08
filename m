From: Danny Kukawka <danny.kukawka@bisect.de>
Subject: [PATCH 20/50] smsc911x: use dev_hw_addr_random() instead of random_ether_addr()
Date: Wed,  8 Feb 2012 22:10:27 +0100
Message-ID: <1328735457-29986-21-git-send-email-danny.kukawka@bisect.de>
References: <1328735457-29986-1-git-send-email-danny.kukawka@bisect.de>
Cc: Danny Kukawka <dkukawka@suse.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Steve Glendinning <steve.glendinning@smsc.com>
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
 drivers/net/ethernet/smsc/smsc911x.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/smsc/smsc911x.c b/drivers/net/ethernet/smsc/smsc911x.c
index 24d2df0..92ab844 100644
--- a/drivers/net/ethernet/smsc/smsc911x.c
+++ b/drivers/net/ethernet/smsc/smsc911x.c
@@ -1834,6 +1834,8 @@ static int smsc911x_set_mac_address(struct net_device *dev, void *p)
 		return -EADDRNOTAVAIL;
 
 	memcpy(dev->dev_addr, addr->sa_data, ETH_ALEN);
+	if (dev->addr_assign_type & NET_ADDR_RANDOM)
+		dev->addr_assign_type ^= NET_ADDR_RANDOM;
 
 	spin_lock_irq(&pdata->mac_lock);
 	smsc911x_set_hw_mac_address(pdata, dev->dev_addr);
@@ -2486,7 +2488,7 @@ static int __devinit smsc911x_drv_probe(struct platform_device *pdev)
 				   "Mac Address is read from LAN911x EEPROM");
 		} else {
 			/* eeprom values are invalid, generate random MAC */
-			random_ether_addr(dev->dev_addr);
+			dev_hw_addr_random(dev, dev->dev_addr);
 			smsc911x_set_hw_mac_address(pdata, dev->dev_addr);
 			SMSC_TRACE(pdata, probe,
 				   "MAC Address is set to random_ether_addr");
-- 
1.7.7.3
