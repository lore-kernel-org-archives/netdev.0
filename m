From: Nicholas Mc Guire <hofrat@osadl.org>
Subject: [PATCH] wil6210: match wait_for_completion_timeout return type
Date: Thu, 14 May 2015 13:41:26 +0200
Message-ID: <1431603686-24029-1-git-send-email-hofrat@osadl.org>
Cc: Kalle Valo <kvalo@codeaurora.org>, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Nicholas Mc Guire <hofrat@osadl.org>
To: Vladimir Kondratiev <qca_vkondrat@qca.qualcomm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Return type of wait_for_completion_timeout is unsigned long not int.
As remain is exclusively used for wait_for_completion_timeout here its
type is simply changed to unsigned long.


API conformance testing for completions with coccinelle spatches are being
used to locate API usage inconsistencies:
./drivers/net/wireless/ath/wil6210/wmi.c:827 
	int return assigned to unsigned long

Patch was compile tested with x86_64_defconfig + CONFIG_ATH_CARDS=m,
CONFIG_WIL6210=m

Patch is against 4.1-rc3 (localversion-next is -next-20150514)


Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>
---
 drivers/net/wireless/ath/wil6210/wmi.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/ath/wil6210/wmi.c b/drivers/net/wireless/ath/wil6210/wmi.c
index 9fe2085..e8d5335 100644
--- a/drivers/net/wireless/ath/wil6210/wmi.c
+++ b/drivers/net/wireless/ath/wil6210/wmi.c
@@ -805,7 +805,7 @@ int wmi_call(struct wil6210_priv *wil, u16 cmdid, void *buf, u16 len,
 	     u16 reply_id, void *reply, u8 reply_size, int to_msec)
 {
 	int rc;
-	int remain;
+	unsigned long remain;
 
 	mutex_lock(&wil->wmi_mutex);
 
-- 
1.7.10.4
