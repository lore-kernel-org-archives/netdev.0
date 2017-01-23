From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net] r8152: don't execute runtime suspend if the tx is not empty
Date: Mon, 23 Jan 2017 14:18:43 +0800
Message-ID: <1394712342-15778-235-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
        <linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Runtime suspend shouldn't be executed if the tx queue is not empty,
because the device is not idle.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 0e99af0..e1466b4 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -32,7 +32,7 @@
 #define NETNEXT_VERSION		"08"
 
 /* Information for net */
-#define NET_VERSION		"6"
+#define NET_VERSION		"7"
 
 #define DRIVER_VERSION		"v1." NETNEXT_VERSION "." NET_VERSION
 #define DRIVER_AUTHOR "Realtek linux nic maintainers <nic_swsd@realtek.com>"
@@ -3574,6 +3574,8 @@ static bool delay_autosuspend(struct r8152 *tp)
 	 */
 	if (!sw_linking && tp->rtl_ops.in_nway(tp))
 		return true;
+	else if (!skb_queue_empty(&tp->tx_queue))
+		return true;
 	else
 		return false;
 }
-- 
2.7.4
