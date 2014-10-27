From: Joe Perches <joe@perches.com>
Subject: [PATCH 07/11] iwlwifi: dvm: Fix probable mask then right shift defect
Date: Sun, 26 Oct 2014 22:25:03 -0700
Message-ID: <83c3bfdd0c8f21fbbcbd9ebb5746a8fb04494fac.1414387334.git.joe@perches.com>
References: <cover.1414387334.git.joe@perches.com>
Cc: Johannes Berg <johannes.berg@intel.com>,
	Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
	Intel Linux Wireless <ilw@linux.intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1414387334.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Precedence of & and >> is not the same and is not left to right.
shift has higher precedence and should be done after the mask.

Add parentheses around the mask.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/iwlwifi/dvm/lib.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/iwlwifi/dvm/lib.c b/drivers/net/wireless/iwlwifi/dvm/lib.c
index 2191621..02e4ede 100644
--- a/drivers/net/wireless/iwlwifi/dvm/lib.c
+++ b/drivers/net/wireless/iwlwifi/dvm/lib.c
@@ -418,8 +418,8 @@ void iwlagn_bt_adjust_rssi_monitor(struct iwl_priv *priv, bool rssi_ena)
 
 static bool iwlagn_bt_traffic_is_sco(struct iwl_bt_uart_msg *uart_msg)
 {
-	return BT_UART_MSG_FRAME3SCOESCO_MSK & uart_msg->frame3 >>
-			BT_UART_MSG_FRAME3SCOESCO_POS;
+	return (BT_UART_MSG_FRAME3SCOESCO_MSK & uart_msg->frame3) >>
+		BT_UART_MSG_FRAME3SCOESCO_POS;
 }
 
 static void iwlagn_bt_traffic_change_work(struct work_struct *work)
-- 
2.1.2
