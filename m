From: Danny Kukawka <danny.kukawka@bisect.de>
Subject: [PATCH 08/50] bnx2x: use dev_hw_addr_random() instead of random_ether_addr()
Date: Wed,  8 Feb 2012 22:10:15 +0100
Message-ID: <1328735457-29986-9-git-send-email-danny.kukawka@bisect.de>
References: <1328735457-29986-1-git-send-email-danny.kukawka@bisect.de>
Cc: Danny Kukawka <dkukawka@suse.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Eilon Greenstein <eilong@broadcom.com>
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
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c  |    2 ++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |    2 +-
 2 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 03f3935..c21acf3 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -3009,6 +3009,8 @@ int bnx2x_change_mac_addr(struct net_device *dev, void *p)
 	}
 
 	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
+	if (dev->addr_assign_type & NET_ADDR_RANDOM)
+		dev->addr_assign_type ^= NET_ADDR_RANDOM;
 
 	if (netif_running(dev))
 		rc = bnx2x_set_eth_mac(bp, true);
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 1e3f978..ff82dc9 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -9605,7 +9605,7 @@ static void __devinit bnx2x_get_mac_hwinfo(struct bnx2x *bp)
 
 	if (BP_NOMCP(bp)) {
 		BNX2X_ERROR("warning: random MAC workaround active\n");
-		random_ether_addr(bp->dev->dev_addr);
+		dev_hw_addr_random(bp->dev, bp->dev->dev_addr);
 	} else if (IS_MF(bp)) {
 		val2 = MF_CFG_RD(bp, func_mf_config[func].mac_upper);
 		val = MF_CFG_RD(bp, func_mf_config[func].mac_lower);
-- 
1.7.7.3
