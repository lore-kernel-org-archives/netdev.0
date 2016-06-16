From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 2/5] net: tlan: don't set unused function argument
Date: Thu, 16 Jun 2016 13:38:23 +0200
Message-ID: <20160616113831.4108439-3-arnd@arndb.de>
References: <20160616113831.4108439-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Samuel Chessman <chessman@tux.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160616113831.4108439-1-arnd@arndb.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We get a warning for tlan_handle_tx_eoc when building with "make W=1"

drivers/net/ethernet/ti/tlan.c: In function 'tlan_handle_tx_eoc':
drivers/net/ethernet/ti/tlan.c:1647:59: error: parameter 'host_int' set but not used [-Werror=unused-but-set-parameter]
 static u32 tlan_handle_tx_eoc(struct net_device *dev, u16 host_int)

This is harmless, but removing the unused assignment lets us avoid
the warning with no downside.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/ethernet/ti/tlan.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/ti/tlan.c b/drivers/net/ethernet/ti/tlan.c
index 561703317312..ece0ea0f6b38 100644
--- a/drivers/net/ethernet/ti/tlan.c
+++ b/drivers/net/ethernet/ti/tlan.c
@@ -1651,7 +1651,6 @@ static u32 tlan_handle_tx_eoc(struct net_device *dev, u16 host_int)
 	dma_addr_t		head_list_phys;
 	u32			ack = 1;
 
-	host_int = 0;
 	if (priv->tlan_rev < 0x30) {
 		TLAN_DBG(TLAN_DEBUG_TX,
 			 "TRANSMIT:  handling TX EOC (Head=%d Tail=%d) -- IRQ\n",
-- 
2.9.0
