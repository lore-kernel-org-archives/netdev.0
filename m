From: Joe Perches <joe@perches.com>
Subject: [PATCH] rsi: Add pr_fmt,__printf, fix format & arg mismatch
Date: Tue, 18 Mar 2014 17:59:47 -0700
Message-ID: <1395190787.8649.5.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Fariya Fatima <fariyaf@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0067.hostedemail.com ([216.40.44.67]:36390 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1758746AbaCSA7u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Mar 2014 20:59:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Emit a prefix for the rsi_dbg messages.

Fix the format and argument mismatch and add
__printf(2, 3) to try to avoid more.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/rsi/rsi_91x_main.c | 2 ++
 drivers/net/wireless/rsi/rsi_91x_mgmt.c | 3 ++-
 drivers/net/wireless/rsi/rsi_main.h     | 2 +-
 3 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/rsi/rsi_91x_main.c b/drivers/net/wireless/rsi/rsi_91x_main.c
index 7367be4..8810862 100644
--- a/drivers/net/wireless/rsi/rsi_91x_main.c
+++ b/drivers/net/wireless/rsi/rsi_91x_main.c
@@ -14,6 +14,8 @@
  * OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/module.h>
 #include <linux/firmware.h>
 #include "rsi_mgmt.h"
diff --git a/drivers/net/wireless/rsi/rsi_91x_mgmt.c b/drivers/net/wireless/rsi/rsi_91x_mgmt.c
index f09c72e..ef37d4b 100644
--- a/drivers/net/wireless/rsi/rsi_91x_mgmt.c
+++ b/drivers/net/wireless/rsi/rsi_91x_mgmt.c
@@ -393,7 +393,8 @@ static int rsi_mgmt_pkt_to_core(struct rsi_common *common,
 
 		msg_len -= pad_bytes;
 		if ((msg_len <= 0) || (!msg)) {
-			rsi_dbg(MGMT_RX_ZONE, "Invalid rx msg of len = %d\n",
+			rsi_dbg(MGMT_RX_ZONE,
+				"%s: Invalid rx msg of len = %d\n",
 				__func__, msg_len);
 			return -EINVAL;
 		}
diff --git a/drivers/net/wireless/rsi/rsi_main.h b/drivers/net/wireless/rsi/rsi_main.h
index e97e6ad..2cb73e7 100644
--- a/drivers/net/wireless/rsi/rsi_main.h
+++ b/drivers/net/wireless/rsi/rsi_main.h
@@ -40,7 +40,7 @@
 #define FSM_MAC_INIT_DONE               6
 
 extern u32 rsi_zone_enabled;
-extern void rsi_dbg(u32 zone, const char *fmt, ...);
+extern __printf(2, 3) void rsi_dbg(u32 zone, const char *fmt, ...);
 
 #define RSI_MAX_VIFS                    1
 #define NUM_EDCA_QUEUES                 4
