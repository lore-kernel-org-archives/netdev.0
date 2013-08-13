From: Alexey Brodkin <Alexey.Brodkin@synopsys.com>
Subject: [PATCH] ethernet/arc/arc_emac - fix NAPI "work > weight" warning
Date: Tue, 13 Aug 2013 17:04:36 +0400
Message-ID: <1376399076-9320-1-git-send-email-abrodkin@synopsys.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexey Brodkin <Alexey.Brodkin@synopsys.com>,
	Vineet Gupta <Vineet.Gupta1@synopsys.com>,
	Mischa Jonker <Mischa.Jonker@synopsys.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <rob.herring@calxeda.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	<linux-kernel@vger.kernel.org>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Initially I improperly set a boundary for maximum number of input
packets to process on NAPI poll ("work") so it might be more than
expected amount ("weight").

This was really harmless but seeing WARN_ON_ONCE on every device boot is
not nice. So trivial fix ("<" instead of "<=") is here.

Signed-off-by: Alexey Brodkin <abrodkin@synopsys.com>

Cc: Vineet Gupta <vgupta@synopsys.com>
Cc: Mischa Jonker <mjonker@synopsys.com>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: Grant Likely <grant.likely@linaro.org>
Cc: Rob Herring <rob.herring@calxeda.com>
Cc: Paul Gortmaker <paul.gortmaker@windriver.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: linux-kernel@vger.kernel.org
---
 drivers/net/ethernet/arc/emac_main.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/arc/emac_main.c b/drivers/net/ethernet/arc/emac_main.c
index f1b121e..55d79cb 100644
--- a/drivers/net/ethernet/arc/emac_main.c
+++ b/drivers/net/ethernet/arc/emac_main.c
@@ -199,7 +199,7 @@ static int arc_emac_rx(struct net_device *ndev, int budget)
 	struct arc_emac_priv *priv = netdev_priv(ndev);
 	unsigned int work_done;
 
-	for (work_done = 0; work_done <= budget; work_done++) {
+	for (work_done = 0; work_done < budget; work_done++) {
 		unsigned int *last_rx_bd = &priv->last_rx_bd;
 		struct net_device_stats *stats = &priv->stats;
 		struct buffer_state *rx_buff = &priv->rx_buff[*last_rx_bd];
-- 
1.8.1.2
