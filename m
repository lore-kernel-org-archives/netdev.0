From: Colin King <colin.king@canonical.com>
Subject: [PATCH] mwifiex: ie_list is an array, so no need to check if NULL
Date: Mon, 28 Mar 2016 16:53:33 +0100
Message-ID: <1459180413-13288-1-git-send-email-colin.king@canonical.com>
Cc: linux-kernel@vger.kernel.org
To: Amitkumar Karwar <akarwar@marvell.com>,
	Nishant Sarmukadam <nishants@marvell.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin Ian King <colin.king@canonical.com>

ap_ie->ie_list is an array of struct mwifiex_ie and can never
be null, so the null check on this array is redundant and can
be removed.

Signed-off-by: Colin Ian King <colin.king@canonical.com>
---
 drivers/net/wireless/marvell/mwifiex/uap_cmd.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/marvell/mwifiex/uap_cmd.c b/drivers/net/wireless/marvell/mwifiex/uap_cmd.c
index 16d95b2..92ce32f 100644
--- a/drivers/net/wireless/marvell/mwifiex/uap_cmd.c
+++ b/drivers/net/wireless/marvell/mwifiex/uap_cmd.c
@@ -694,7 +694,7 @@ static int mwifiex_uap_custom_ie_prepare(u8 *tlv, void *cmd_buf, u16 *ie_size)
 	struct mwifiex_ie_list *ap_ie = cmd_buf;
 	struct mwifiex_ie_types_header *tlv_ie = (void *)tlv;
 
-	if (!ap_ie || !ap_ie->len || !ap_ie->ie_list)
+	if (!ap_ie || !ap_ie->len)
 		return -1;
 
 	*ie_size += le16_to_cpu(ap_ie->len) +
-- 
2.7.4
