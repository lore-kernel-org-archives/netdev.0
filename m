From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 05/11] r8152: adjust rtl8153_runtime_enable function
Date: Fri, 9 Jun 2017 17:11:42 +0800
Message-ID: <1394712342-15778-265-Taiwan-albertk@realtek.com>
References: <1394712342-15778-260-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
        <linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-260-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adjust the order of rtl8153_runtime_enable() according to the
suggestion from the engineer.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index e569c48..32e83fd 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -2551,13 +2551,13 @@ static void rtl_runtime_suspend_enable(struct r8152 *tp, bool enable)
 
 static void rtl8153_runtime_enable(struct r8152 *tp, bool enable)
 {
-	rtl_runtime_suspend_enable(tp, enable);
-
 	if (enable) {
 		r8153_u1u2en(tp, false);
 		r8153_u2p3en(tp, false);
 		r8153_mac_clk_spd(tp, true);
+		rtl_runtime_suspend_enable(tp, true);
 	} else {
+		rtl_runtime_suspend_enable(tp, false);
 		r8153_mac_clk_spd(tp, false);
 		r8153_u2p3en(tp, true);
 		r8153_u1u2en(tp, true);
-- 
2.7.4
