From: Xing Zheng <zhengxing@rock-chips.com>
Subject: [PATCH 3/4] net: ethernet: arc: Add support emac for RK3036
Date: Wed, 23 Dec 2015 17:19:49 +0800
Message-ID: <1450862390-407-3-git-send-email-zhengxing@rock-chips.com>
References: <1450862390-407-1-git-send-email-zhengxing@rock-chips.com>
Cc: keescook@google.com, leozwang@google.com, heiko@sntech.de,
	Xing Zheng <zhengxing@rock-chips.com>,
	"David S. Miller" <davem@davemloft.net>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Geert Uytterhoeven <geert@linux-m68k.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: linux-rockchip@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from regular2.263xmail.com ([211.157.152.3]:40397 "EHLO
	regular2.263xmail.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754234AbbLWJUK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2015 04:20:10 -0500
Received: from regular1.263xmail.com (unknown [192.168.165.185])
	by regular2.263xmail.com (Postfix) with ESMTP id 8923A1EBB5
	for <netdev@vger.kernel.org>; Wed, 23 Dec 2015 17:20:05 +0800 (CST)
In-Reply-To: <1450862390-407-1-git-send-email-zhengxing@rock-chips.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The RK3036's GRFs offset are different with RK3066/RK3188, and need to set
mac TX/RX clock before probe emac.

Signed-off-by: Xing Zheng <zhengxing@rock-chips.com>
---

 drivers/net/ethernet/arc/Kconfig         |    4 ++--
 drivers/net/ethernet/arc/emac_rockchip.c |    9 +++++++--
 2 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/arc/Kconfig b/drivers/net/ethernet/arc/Kconfig
index 52a6b16..6890451 100644
--- a/drivers/net/ethernet/arc/Kconfig
+++ b/drivers/net/ethernet/arc/Kconfig
@@ -34,9 +34,9 @@ config EMAC_ROCKCHIP
 	select ARC_EMAC_CORE
 	depends on OF_IRQ && OF_NET && REGULATOR && HAS_DMA
 	---help---
-	  Support for Rockchip RK3066/RK3188 EMAC ethernet controllers.
+	  Support for Rockchip RK3036/RK3066/RK3188 EMAC ethernet controllers.
 	  This selects Rockchip SoC glue layer support for the
-	  emac device driver. This driver is used for RK3066/RK3188
+	  emac device driver. This driver is used for RK3036/RK3066/RK3188
 	  EMAC ethernet controller.
 
 endif # NET_VENDOR_ARC
diff --git a/drivers/net/ethernet/arc/emac_rockchip.c b/drivers/net/ethernet/arc/emac_rockchip.c
index d1a9c28..2433eeb 100644
--- a/drivers/net/ethernet/arc/emac_rockchip.c
+++ b/drivers/net/ethernet/arc/emac_rockchip.c
@@ -69,6 +69,10 @@ static void emac_rockchip_set_mac_speed(void *priv, unsigned int speed)
 
 static const struct emac_rockchip_soc_data emac_rockchip_dt_data[] = {
 	{
+	  .grf_offset = 0x140,   .grf_mode_offset = 8,
+	  .grf_speed_offset = 9, .need_div_macclk = 1
+	}, /* rk3036 */
+	{
 	  .grf_offset = 0x154,   .grf_mode_offset = 0,
 	  .grf_speed_offset = 1, .need_div_macclk = 0
 	}, /* rk3066 */
@@ -79,8 +83,9 @@ static const struct emac_rockchip_soc_data emac_rockchip_dt_data[] = {
 };
 
 static const struct of_device_id emac_rockchip_dt_ids[] = {
-	{ .compatible = "rockchip,rk3066-emac", .data = &emac_rockchip_dt_data[0] },
-	{ .compatible = "rockchip,rk3188-emac", .data = &emac_rockchip_dt_data[1] },
+	{ .compatible = "rockchip,rk3036-emac", .data = &emac_rockchip_dt_data[0] },
+	{ .compatible = "rockchip,rk3066-emac", .data = &emac_rockchip_dt_data[1] },
+	{ .compatible = "rockchip,rk3188-emac", .data = &emac_rockchip_dt_data[2] },
 	{ /* Sentinel */ }
 };
 
-- 
1.7.9.5
