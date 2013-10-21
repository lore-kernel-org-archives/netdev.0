From: Mariusz Ceier <mceier+kernel@gmail.com>
Subject: [PATCH] davinci_emac.c: Fix IFF_ALLMULTI setup
Date: Mon, 21 Oct 2013 18:59:37 +0200
Message-ID: <1382374777-24200-1-git-send-email-mceier+kernel@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Mariusz Ceier <mceier+kernel@gmail.com>
To: "David S. Miller" <davem@davemloft.net>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	"Lad Prabhakar" <prabhakar.csengg@gmail.com>,
	Jingoo Han <jg1.han@samsung.com>, Jiri Pirko <jiri@resnulli.us>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When IFF_ALLMULTI flag is set on interface and IFF_PROMISC isn't,
emac_dev_mcast_set should only enable RX of multicasts and reset
MACHASH registers.

It does this, but afterwards it either sets up multicast MACs
filtering or disables RX of multicasts and resets MACHASH registers
again, rendering IFF_ALLMULTI flag useless.

This patch fixes emac_dev_mcast_set, so that multicast MACs filtering and
disabling of RX of multicasts are skipped when IFF_ALLMULTI flag is set.

Tested with kernel 2.6.37.

Signed-off-by: Mariusz Ceier <mceier+kernel@gmail.com>
---
 drivers/net/ethernet/ti/davinci_emac.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/ti/davinci_emac.c b/drivers/net/ethernet/ti/davinci_emac.c
index 67df09e..ff3bf0e 100644
--- a/drivers/net/ethernet/ti/davinci_emac.c
+++ b/drivers/net/ethernet/ti/davinci_emac.c
@@ -876,7 +876,7 @@ static void emac_dev_mcast_set(struct net_device *ndev)
 		    netdev_mc_count(ndev) > EMAC_DEF_MAX_MULTICAST_ADDRESSES) {
 			mbp_enable = (mbp_enable | EMAC_MBP_RXMCAST);
 			emac_add_mcast(priv, EMAC_ALL_MULTI_SET, NULL);
-		}
+		} else
 		if (!netdev_mc_empty(ndev)) {
 			struct netdev_hw_addr *ha;
 
-- 
1.8.4
