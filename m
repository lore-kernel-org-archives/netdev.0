From: Nicholas Mc Guire <hofrat@osadl.org>
Subject: [PATCH] ath9k_htc: wmi: match wait_for_completion_timeout return type
Date: Thu, 14 May 2015 18:43:41 +0200
Message-ID: <1431621821-8173-1-git-send-email-hofrat@osadl.org>
Cc: Kalle Valo <kvalo@codeaurora.org>, linux-wireless@vger.kernel.org,
	ath9k-devel@venema.h4ckr.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Nicholas Mc Guire <hofrat@osadl.org>
To: QCA ath9k Development <ath9k-devel@qca.qualcomm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Return type of wait_for_completion_timeout is unsigned long not int.
As time_left is exclusively used for wait_for_completion_timeout here its
type is simply changed to unsigned long.

API conformance testing for completions with coccinelle spatches are being
used to locate API usage inconsistencies:
./drivers/net/wireless/ath/ath9k/wmi.c:331
	int return assigned to unsigned long

Patch was compile tested with x86_64_defconfig + CONFIG_ATH_CARDS=m,
CONFIG_ATH9K_HTC=m

Patch is against 4.1-rc3 (localversion-next is -next-20150514)

Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>
---
 drivers/net/wireless/ath/ath9k/wmi.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/wireless/ath/ath9k/wmi.c b/drivers/net/wireless/ath/ath9k/wmi.c
index ca533b4..a1458db 100644
--- a/drivers/net/wireless/ath/ath9k/wmi.c
+++ b/drivers/net/wireless/ath/ath9k/wmi.c
@@ -299,7 +299,8 @@ int ath9k_wmi_cmd(struct wmi *wmi, enum wmi_cmd_id cmd_id,
 		       sizeof(struct wmi_cmd_hdr);
 	struct sk_buff *skb;
 	u8 *data;
-	int time_left, ret = 0;
+	unsigned long time_left;
+	int ret = 0;
 
 	if (ah->ah_flags & AH_UNPLUGGED)
 		return 0;
-- 
1.7.10.4
