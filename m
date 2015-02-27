From: Filip Ayazi <filipayazi@gmail.com>
Subject: [PATCH] iwlwifi: mvm: check time event is over before disconnecting
Date: Sat, 28 Feb 2015 00:10:00 +0100
Message-ID: <1425078600-29882-1-git-send-email-filipayazi@gmail.com>
Cc: ilw@linux.intel.com, linux-wireless@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Filip Ayazi <filipayazi@gmail.com>
To: kvalo@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f176.google.com ([74.125.82.176]:35400 "EHLO
	mail-we0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755244AbbB0XLJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 18:11:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On the 7260 time event was often ended before end_time and connections failed
with "No association and the time event is over already...".
This checks that the time event is actually over before disconnecting.

Signed-off-by: Filip Ayazi <filipayazi@gmail.com>
---
 drivers/net/wireless/iwlwifi/mvm/time-event.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/wireless/iwlwifi/mvm/time-event.c b/drivers/net/wireless/iwlwifi/mvm/time-event.c
index 54fafbf..b0aa892 100644
--- a/drivers/net/wireless/iwlwifi/mvm/time-event.c
+++ b/drivers/net/wireless/iwlwifi/mvm/time-event.c
@@ -256,7 +256,8 @@ static void iwl_mvm_te_handle_notif(struct iwl_mvm *mvm,
 		}
 	}
 
-	if (le32_to_cpu(notif->action) & TE_V2_NOTIF_HOST_EVENT_END) {
+	if (le32_to_cpu(notif->action) & TE_V2_NOTIF_HOST_EVENT_END &&
+	    time_after(jiffies, te_data->end_jiffies)) {
 		IWL_DEBUG_TE(mvm,
 			     "TE ended - current time %lu, estimated end %lu\n",
 			     jiffies, te_data->end_jiffies);
-- 
1.9.1
