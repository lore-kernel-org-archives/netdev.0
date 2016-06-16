From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net 3/3] r8152: correct the rx early size
Date: Thu, 16 Jun 2016 10:55:19 +0800
Message-ID: <1394712342-15778-182-Taiwan-albertk@realtek.com>
References: <1394712342-15778-179-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-179-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The rx early size should be

	(agg_buf_sz - packet size) / 8

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index f5bc351..4e257b8 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -31,7 +31,7 @@
 #define NETNEXT_VERSION		"08"
 
 /* Information for net */
-#define NET_VERSION		"3"
+#define NET_VERSION		"4"
 
 #define DRIVER_VERSION		"v1." NETNEXT_VERSION "." NET_VERSION
 #define DRIVER_AUTHOR "Realtek linux nic maintainers <nic_swsd@realtek.com>"
@@ -2174,7 +2174,7 @@ static void r8153_set_rx_early_timeout(struct r8152 *tp)
 static void r8153_set_rx_early_size(struct r8152 *tp)
 {
 	u32 mtu = tp->netdev->mtu;
-	u32 ocp_data = (agg_buf_sz - mtu - VLAN_ETH_HLEN - VLAN_HLEN) / 4;
+	u32 ocp_data = (agg_buf_sz - mtu - VLAN_ETH_HLEN - VLAN_HLEN) / 8;
 
 	ocp_write_word(tp, MCU_TYPE_USB, USB_RX_EARLY_SIZE, ocp_data);
 }
-- 
2.4.11
