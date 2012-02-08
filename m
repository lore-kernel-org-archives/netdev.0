From: Danny Kukawka <danny.kukawka@bisect.de>
Subject: [PATCH 21/50] smsc9420: use dev_hw_addr_random() instead of random_ether_addr()
Date: Wed,  8 Feb 2012 22:10:28 +0100
Message-ID: <1328735457-29986-22-git-send-email-danny.kukawka@bisect.de>
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

Signed-off-by: Danny Kukawka <danny.kukawka@bisect.de>
---
 drivers/net/ethernet/smsc/smsc9420.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/smsc/smsc9420.c b/drivers/net/ethernet/smsc/smsc9420.c
index a9efbdf..51013df 100644
--- a/drivers/net/ethernet/smsc/smsc9420.c
+++ b/drivers/net/ethernet/smsc/smsc9420.c
@@ -509,7 +509,7 @@ static void smsc9420_check_mac_address(struct net_device *dev)
 			smsc_dbg(PROBE, "Mac Address is read from EEPROM");
 		} else {
 			/* eeprom values are invalid, generate random MAC */
-			random_ether_addr(dev->dev_addr);
+			dev_hw_addr_random(dev, dev->dev_addr);
 			smsc9420_set_mac_address(dev);
 			smsc_dbg(PROBE,
 				"MAC Address is set to random_ether_addr");
-- 
1.7.7.3
