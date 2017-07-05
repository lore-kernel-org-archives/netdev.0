From: Nicolas Ferre <nicolas.ferre@microchip.com>
Subject: [PATCH] net: macb: Adding Support for Jumbo Frames up to 10240 Bytes in SAMA5D3
Date: Wed, 5 Jul 2017 17:36:16 +0200
Message-ID: <20170705153616.15965-1-nicolas.ferre@microchip.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexandre Belloni <alexandre.belloni@free-electrons.com>,
        <linux-arm-kernel@lists.infradead.org>,
        <linux-kernel@vger.kernel.org>,
        vishnuvardhan <vardhanraj4143@gmail.com>,
        Nicolas Ferre <nicolas.ferre@microchip.com>
To: <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>,
        <rafalo@cadence.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: vishnuvardhan <vardhanraj4143@gmail.com>

As per the SAMA5D3 device specification it supports Jumbo frames.
But the suggested flag and length of bytes it supports was not updated
in this driver config_structure.
The maximum jumbo frames the device supports :
10240 bytes as per the device spec.

While changing the MTU value greater than 1500, it threw error:
sudo ifconfig eth1 mtu 9000
SIOCSIFMTU: Invalid argument

Add this support to driver so that it works as expected and designed.

Signed-off-by: vishnuvardhan <vardhanraj4143@gmail.com>
[nicolas.ferre@microchip.com: modify slightly commit msg]
Signed-off-by: Nicolas Ferre <nicolas.ferre@microchip.com>
---
 drivers/net/ethernet/cadence/macb_main.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/cadence/macb_main.c b/drivers/net/ethernet/cadence/macb_main.c
index e69ebdd65658..26d25749c3e4 100644
--- a/drivers/net/ethernet/cadence/macb_main.c
+++ b/drivers/net/ethernet/cadence/macb_main.c
@@ -3314,10 +3314,11 @@ static const struct macb_config sama5d2_config = {
 
 static const struct macb_config sama5d3_config = {
 	.caps = MACB_CAPS_SG_DISABLED | MACB_CAPS_GIGABIT_MODE_AVAILABLE
-	      | MACB_CAPS_USRIO_DEFAULT_IS_MII_GMII,
+	      | MACB_CAPS_USRIO_DEFAULT_IS_MII_GMII | MACB_CAPS_JUMBO,
 	.dma_burst_length = 16,
 	.clk_init = macb_clk_init,
 	.init = macb_init,
+	.jumbo_max_len = 10240,
 };
 
 static const struct macb_config sama5d4_config = {
-- 
2.9.0
