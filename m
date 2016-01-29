From: Sudip Mukherjee <sudipm.mukherjee@gmail.com>
Subject: [PATCH] mac80211: fix memory leak
Date: Fri, 29 Jan 2016 15:19:04 +0530
Message-ID: <1454060944-11320-1-git-send-email-sudipm.mukherjee@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org,
	Sudip Mukherjee <sudipm.mukherjee@gmail.com>
To: Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On error we jumped to the error label and returned the error code but we
missed releasing sinfo.

Signed-off-by: Sudip Mukherjee <sudip@vectorindia.org>
---
 net/mac80211/sta_info.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/mac80211/sta_info.c b/net/mac80211/sta_info.c
index 6c198e6..36e75c4 100644
--- a/net/mac80211/sta_info.c
+++ b/net/mac80211/sta_info.c
@@ -561,6 +561,7 @@ static int sta_info_insert_finish(struct sta_info *sta) __acquires(RCU)
 	__cleanup_single_sta(sta);
  out_err:
 	mutex_unlock(&local->sta_mtx);
+	kfree(sinfo);
 	rcu_read_lock();
 	return err;
 }
-- 
1.9.1
