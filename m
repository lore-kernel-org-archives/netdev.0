From: Chaehyun Lim <chaehyun.lim@gmail.com>
Subject: [PATCH] ath6kl: fix return value in ath6kl_wmi_set_pvb_cmd
Date: Sun, 18 Sep 2016 15:30:24 +0900
Message-ID: <20160918063024.2535-1-chaehyun.lim@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        Chaehyun Lim <chaehyun.lim@gmail.com>
To: kvalo@qca.qualcomm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:36179 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754009AbcIRGah (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 18 Sep 2016 02:30:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When building with W=1, we got one warning as belows:
drivers/net/wireless/ath/ath6kl/wmi.c:3509:6: warning: variable ‘ret’
set but not used [-Wunused-but-set-variable]

At the end of ath6kl_wmi_set_pvb_cmd, it is returned by 0 regardless of
return value of ath6kl_wmi_cmd_send.
This patch fixes return value from 0 to ret that has result of
ath6kl_wmi_cmd_send execution.

Signed-off-by: Chaehyun Lim <chaehyun.lim@gmail.com>
---
 drivers/net/wireless/ath/ath6kl/wmi.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/ath/ath6kl/wmi.c b/drivers/net/wireless/ath/ath6kl/wmi.c
index b8cf04d..3fd1cc9 100644
--- a/drivers/net/wireless/ath/ath6kl/wmi.c
+++ b/drivers/net/wireless/ath/ath6kl/wmi.c
@@ -3520,7 +3520,7 @@ int ath6kl_wmi_set_pvb_cmd(struct wmi *wmi, u8 if_idx, u16 aid,
 	ret = ath6kl_wmi_cmd_send(wmi, if_idx, skb, WMI_AP_SET_PVB_CMDID,
 				  NO_SYNC_WMIFLAG);
 
-	return 0;
+	return ret;
 }
 
 int ath6kl_wmi_set_rx_frame_format_cmd(struct wmi *wmi, u8 if_idx,
-- 
2.9.3
