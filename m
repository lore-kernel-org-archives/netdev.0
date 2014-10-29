From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] iwlwifi: cleanup a mask shift in iwlagn_bt_traffic_is_sco()
Date: Wed, 29 Oct 2014 19:08:27 +0300
Message-ID: <20141029160827.GD5290@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Emmanuel Grumbach <emmanuel.grumbach@intel.com>,
	Intel Linux Wireless <ilw@linux.intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Johannes Berg <johannes.berg@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The shift operation is higher precedence so the code is wrong and it
sets of a static checker warning.  But it doesn't affect real life
because BT_UART_MSG_FRAME3SCOESCO_POS is zero so the shift is a no-op.

I have re-written it in normal style and with parenthesis as a cleanup
and to silence the static checker warning.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/wireless/iwlwifi/dvm/lib.c b/drivers/net/wireless/iwlwifi/dvm/lib.c
index 2191621..065d3d5 100644
--- a/drivers/net/wireless/iwlwifi/dvm/lib.c
+++ b/drivers/net/wireless/iwlwifi/dvm/lib.c
@@ -418,7 +418,7 @@ void iwlagn_bt_adjust_rssi_monitor(struct iwl_priv *priv, bool rssi_ena)
 
 static bool iwlagn_bt_traffic_is_sco(struct iwl_bt_uart_msg *uart_msg)
 {
-	return BT_UART_MSG_FRAME3SCOESCO_MSK & uart_msg->frame3 >>
+	return (uart_msg->frame3 & BT_UART_MSG_FRAME3SCOESCO_MSK) >>
 			BT_UART_MSG_FRAME3SCOESCO_POS;
 }
 
