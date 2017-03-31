From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [PATCH] net: ethernet: ti: cpsw: wake tx queues on ndo_tx_timeout
Date: Fri, 31 Mar 2017 18:41:23 -0500
Message-ID: <20170331234123.15607-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
        <linux-omap@vger.kernel.org>,
        Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>,
        Grygorii Strashko <grygorii.strashko@ti.com>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In case, if TX watchdog is fired some or all netdev TX queues will be
stopped and as part of recovery it is required not only to drain and
reinitailize CPSW TX channeles, but also wake up stoppted TX queues what
doesn't happen now and netdevice will stop transmiting data until
reopenned.

Hence, add netif_tx_wake_all_queues() call in .ndo_tx_timeout() to complete
recovery and restore TX path.

Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
---
 drivers/net/ethernet/ti/cpsw.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 86d6f10..71fd4ef 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -1819,6 +1819,8 @@ static void cpsw_ndo_tx_timeout(struct net_device *ndev)
 	}
 
 	cpsw_intr_enable(cpsw);
+	netif_trans_update(ndev);
+	netif_tx_wake_all_queues(ndev);
 }
 
 static int cpsw_ndo_set_mac_address(struct net_device *ndev, void *p)
-- 
2.10.1
