From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH v3 3/3] rsi: Replace variable initialisations by assignments
 in rsi_send_data_pkt()
Date: Fri, 15 Jan 2016 14:12:01 +0100
Message-ID: <5698F021.1070707@users.sourceforge.net>
References: <566ABCD9.1060404@users.sourceforge.net>
 <5687E169.4070704@users.sourceforge.net>
 <5698EE65.7010607@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org,
	Julia Lawall <julia.lawall@lip6.fr>,
	"John W. Linville" <linville@tuxdriver.com>
To: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	Fariya Fatima <fariyaf@gmail.com>,
	Jahnavi Meher <jahnavi.meher@gmail.com>,
	Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5698EE65.7010607@users.sourceforge.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Fri, 15 Jan 2016 13:40:22 +0100

Replace explicit initialisation for two local variables at the beginning
by assignments.

Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 drivers/net/wireless/rsi/rsi_91x_pkt.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/wireless/rsi/rsi_91x_pkt.c b/drivers/net/wireless/rsi/rsi_91x_pkt.c
index 4322df1..2c18c01 100644
--- a/drivers/net/wireless/rsi/rsi_91x_pkt.c
+++ b/drivers/net/wireless/rsi/rsi_91x_pkt.c
@@ -26,12 +26,12 @@
  */
 int rsi_send_data_pkt(struct rsi_common *common, struct sk_buff *skb)
 {
-	struct rsi_hw *adapter = common->priv;
+	struct rsi_hw *adapter;
 	struct ieee80211_hdr *tmp_hdr;
 	struct ieee80211_tx_info *info;
 	struct skb_info *tx_params;
 	struct ieee80211_bss_conf *bss;
-	int status = -EINVAL;
+	int status;
 	u8 ieee80211_size = MIN_802_11_HDR_LEN;
 	u8 extnd_size;
 	__le16 *frame_desc;
@@ -41,8 +41,10 @@ int rsi_send_data_pkt(struct rsi_common *common, struct sk_buff *skb)
 	bss = &info->control.vif->bss_conf;
 	tx_params = (struct skb_info *)info->driver_data;
 
-	if (!bss->assoc)
+	if (!bss->assoc) {
+		status = -EINVAL;
 		goto err;
+	}
 
 	tmp_hdr = (struct ieee80211_hdr *)&skb->data[0];
 	seq_num = (le16_to_cpu(tmp_hdr->seq_ctrl) >> 4);
@@ -97,7 +99,7 @@ int rsi_send_data_pkt(struct rsi_common *common, struct sk_buff *skb)
 	frame_desc[7] = cpu_to_le16(((tx_params->tid & 0xf) << 4) |
 				    (skb->priority & 0xf) |
 				    (tx_params->sta_id << 8));
-
+	adapter = common->priv;
 	status = adapter->host_intf_write_pkt(common->priv,
 					      skb->data,
 					      skb->len);
-- 
2.6.3
