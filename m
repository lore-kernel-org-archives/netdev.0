From: Nicholas Mc Guire <hofrat@osadl.org>
Subject: [PATCH 1/2] mesh_plink: use msecs_to_jiffies for proper time conversion
Date: Mon,  2 Mar 2015 04:54:13 -0500
Message-ID: <1425290054-26631-1-git-send-email-hofrat@osadl.org>
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Nicholas Mc Guire <hofrat@osadl.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is primarily an API consolidation and should make things more readable
it replaces var * HZ / 1000 by msecs_to_jiffies(var) which also handles
corner cases correctly.

There is a change of behavior as e.g. for HZ 100, t * HZ / 1000 will
return 0 for t < 10 but msecs_to_jiffies will return at least 1 always.

Signed-off-by: Nicholas Mc Guire <hofrat@osadl.org>
---

Patch was only compile tested with x86_64_defconfig + CONFIG_MAC80211_MESH=y

Patch is against 4.0-rc1 (localversion-next is -next-20150302)

 net/mac80211/mesh_plink.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/mac80211/mesh_plink.c b/net/mac80211/mesh_plink.c
index b488e18..4eefd5d 100644
--- a/net/mac80211/mesh_plink.c
+++ b/net/mac80211/mesh_plink.c
@@ -17,7 +17,7 @@
 #define PLINK_GET_PLID(p) (p + 4)
 
 #define mod_plink_timer(s, t) (mod_timer(&s->plink_timer, \
-				jiffies + HZ * t / 1000))
+				jiffies + msecs_to_jiffies(t)))
 
 enum plink_event {
 	PLINK_UNDEFINED,
@@ -623,7 +623,7 @@ static void mesh_plink_timer(unsigned long data)
 
 static inline void mesh_plink_timer_set(struct sta_info *sta, int timeout)
 {
-	sta->plink_timer.expires = jiffies + (HZ * timeout / 1000);
+	sta->plink_timer.expires = jiffies + msecs_to_jiffies(timeout);
 	sta->plink_timer.data = (unsigned long) sta;
 	sta->plink_timer.function = mesh_plink_timer;
 	sta->plink_timeout = timeout;
-- 
1.7.10.4
