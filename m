From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH 14/14] d80211: fix invalid pointer dereference
Date: Wed, 27 Sep 2006 17:50:59 +0200 (CEST)
Message-ID: <20060927155059.4FD543BA338@silver.suse.cz>
References: <20060927175006.637430015.midnight@suse.cz>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:51340 "EHLO silver.suse.cz")
	by vger.kernel.org with ESMTP id S964987AbWI0Pty (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2006 11:49:54 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060927175006.637430015.midnight@suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When deleted_sta_list is nonempty and sta_list is empty in
sta_info_proc_add_task, an invalid sta pointer is dereferenced.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/d80211/sta_info.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

388092c43ba32071c0102c28e2cf43c0dc782566
diff --git a/net/d80211/sta_info.c b/net/d80211/sta_info.c
index 9397c48..a326c4a 100644
--- a/net/d80211/sta_info.c
+++ b/net/d80211/sta_info.c
@@ -354,13 +354,14 @@ static void sta_info_proc_add_task(void 
 	}
 
 	while (1) {
+		sta = NULL;
 		spin_lock_bh(&local->sta_lock);
-		list_for_each_entry_safe(sta, tmp, &local->sta_list, list) {
-			if (!sta->sysfs_registered) {
+		list_for_each_entry(tmp, &local->sta_list, list) {
+			if (!tmp->sysfs_registered) {
+				sta = tmp;
 				__sta_info_get(sta);
 				break;
 			}
-			sta = NULL;
 		}
 		spin_unlock_bh(&local->sta_lock);
 
-- 
1.3.0

