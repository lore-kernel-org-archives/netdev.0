From: Baoyou Xie <baoyou.xie@linaro.org>
Subject: [PATCH] cxgb4: mark cxgb_setup_tc() static
Date: Fri, 30 Sep 2016 15:34:25 +0800
Message-ID: <1475220865-18321-1-git-send-email-baoyou.xie@linaro.org>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        arnd@arndb.de, baoyou.xie@linaro.org, xie.baoyou@zte.com.cn,
        han.fei@zte.com.cn, tang.qiang007@zte.com.cn
To: hariprasad@chelsio.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We get 1 warning when building kernel with W=1:
drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c:2715:5: warning: no previous prototype for 'cxgb_setup_tc' [-Wmissing-prototypes]

In fact, this function is only used in the file in which it is
declared and don't need a declaration, but can be made static.
so this patch marks this function with 'static'.

Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index c8a5c43..08e69d3 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -2712,8 +2712,8 @@ static int cxgb_set_tx_maxrate(struct net_device *dev, int index, u32 rate)
 	return err;
 }
 
-int cxgb_setup_tc(struct net_device *dev, u32 handle, __be16 proto,
-		  struct tc_to_netdev *tc)
+static int cxgb_setup_tc(struct net_device *dev, u32 handle, __be16 proto,
+			 struct tc_to_netdev *tc)
 {
 	struct port_info *pi = netdev2pinfo(dev);
 	struct adapter *adap = netdev2adap(dev);
-- 
2.7.4
