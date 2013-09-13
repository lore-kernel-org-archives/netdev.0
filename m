From: Chris Metcalf <cmetcalf@tilera.com>
Subject: [PATCH] ath9k: mark wmi_event_swba as __packed
Date: Fri, 13 Sep 2013 12:14:09 -0400
Message-ID: <201309131617.r8DGHu7H000791@farm-0013.internal.tilera.com>
Mime-Version: 1.0
Content-Type: text/plain
To: "Luis R. Rodriguez" <mcgrof@qca.qualcomm.com>,
	Jouni Malinen <jouni@qca.qualcomm.com>,
	Vasanthakumar Thiagarajan <vthiagar@qca.qualcomm.com>,
	Senthil Balasubramanian <senthilb@qca.qualcomm.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	<linux-wireless@vger.kernel.org>, <ath9k-devel@venema.h4ckr.net>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The other structures in wmi.h are already marked this way.
Without this marking, we get an unaliged access panic in the tilegx kernel:

Starting stack dump of tid 0, pid 0 (swapper) on cpu 35 at cycle 198675113844
  frame 0: 0xfffffff7103ada90 ath9k_htc_swba+0x120/0x618 [ath9k_htc]
  frame 1: 0xfffffff7103a4b10 ath9k_wmi_event_tasklet+0x1b0/0x270 [ath9k_htc]
  frame 2: 0xfffffff700326570 tasklet_action+0x148/0x298
  [...]

Signed-off-by: Chris Metcalf <cmetcalf@tilera.com>
---
 drivers/net/wireless/ath/ath9k/wmi.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/ath/ath9k/wmi.h b/drivers/net/wireless/ath/ath9k/wmi.h
index fde6da6..0db37f2 100644
--- a/drivers/net/wireless/ath/ath9k/wmi.h
+++ b/drivers/net/wireless/ath/ath9k/wmi.h
@@ -39,7 +39,7 @@ struct wmi_fw_version {
 struct wmi_event_swba {
 	__be64 tsf;
 	u8 beacon_pending;
-};
+} __packed;
 
 /*
  * 64 - HTC header - WMI header - 1 / txstatus
-- 
1.8.3.1
