From: Su Kang Yin <cantona@cantona.net>
Subject: [PATCH] mac80211_hwsim: unregister genetlink family properly
Date: Fri,  7 Aug 2015 16:54:10 +0800
Message-ID: <1438937650-361-1-git-send-email-cantona@cantona.net>
Cc: Kalle Valo <kvalo@codeaurora.org>, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Su Kang Yin <cantona@cantona.net>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

During hwsim_init_netlink(), we should call genl_unregister_family()
if failed on netlink_register_notifier() since the genetlink is
already registered.

Signed-off-by: Su Kang Yin <cantona@cantona.net>
---
 drivers/net/wireless/mac80211_hwsim.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/wireless/mac80211_hwsim.c b/drivers/net/wireless/mac80211_hwsim.c
index 99e873d..16d953e 100644
--- a/drivers/net/wireless/mac80211_hwsim.c
+++ b/drivers/net/wireless/mac80211_hwsim.c
@@ -3120,8 +3120,10 @@ static int hwsim_init_netlink(void)
 		goto failure;
 
 	rc = netlink_register_notifier(&hwsim_netlink_notifier);
-	if (rc)
+	if (rc) {
+		genl_unregister_family(&hwsim_genl_family);
 		goto failure;
+	}
 
 	return 0;
 
-- 
1.9.1
