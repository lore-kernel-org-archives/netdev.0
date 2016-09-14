From: <sean.wang@mediatek.com>
Subject: [PATCH net-next v2 4/7] net: ethernet: mediatek: add controlling power domain the ethernet belongs to
Date: Wed, 14 Sep 2016 23:13:18 +0800
Message-ID: <1473866001-9805-5-git-send-email-sean.wang@mediatek.com>
References: <1473866001-9805-1-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nbd@openwrt.org>, <netdev@vger.kernel.org>,
        <linux-mediatek@lists.infradead.org>, <keyhaede@gmail.com>,
        <objelf@gmail.com>, Sean Wang <sean.wang@mediatek.com>
To: <john@phrozen.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw01.mediatek.com ([210.61.82.183]:10310 "EHLO
        mailgw01.mediatek.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
        with ESMTP id S1762170AbcINPNc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 14 Sep 2016 11:13:32 -0400
In-Reply-To: <1473866001-9805-1-git-send-email-sean.wang@mediatek.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sean Wang <sean.wang@mediatek.com>

introduce power domain control which the digital circuit of
the ethernet belongs to inside the flow of hardware initialization
and deinitialization which helps the entire ethernet hardware block
could restart cleanly and completely as being back to the initial
state when the whole machine reboot.

Signed-off-by: Sean Wang <sean.wang@mediatek.com>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index 917a49c6..fd5d064 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -18,6 +18,7 @@
 #include <linux/mfd/syscon.h>
 #include <linux/regmap.h>
 #include <linux/clk.h>
+#include <linux/pm_runtime.h>
 #include <linux/if_vlan.h>
 #include <linux/reset.h>
 #include <linux/tcp.h>
@@ -1417,6 +1418,9 @@ static int __init mtk_hw_init(struct mtk_eth *eth)
 {
 	int i;
 
+	pm_runtime_enable(eth->dev);
+	pm_runtime_get_sync(eth->dev);
+
 	clk_prepare_enable(eth->clks[MTK_CLK_ETHIF]);
 	clk_prepare_enable(eth->clks[MTK_CLK_ESW]);
 	clk_prepare_enable(eth->clks[MTK_CLK_GP1]);
@@ -1484,6 +1488,9 @@ static int mtk_hw_deinit(struct mtk_eth *eth)
 	clk_disable_unprepare(eth->clks[MTK_CLK_ESW]);
 	clk_disable_unprepare(eth->clks[MTK_CLK_ETHIF]);
 
+	pm_runtime_put_sync(eth->dev);
+	pm_runtime_disable(eth->dev);
+
 	return 0;
 }
 
-- 
1.9.1
