From: Andreea-Cristina Bernat <bernat.ada-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] mac80211: Replace rcu_dereference() with rcu_access_pointer()
Date: Sun, 17 Aug 2014 16:18:02 +0300
Message-ID: <20140817131801.GA24286@ada>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: paulmck-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
To: johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org, linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The "rcu_dereference()" calls are used directly in conditions.
Since their return values are never dereferenced it is recommended to
use "rcu_access_pointer()" instead of "rcu_dereference()".
Therefore, this patch makes the replacements.

The following Coccinelle semantic patch was used:
@@
@@

(
 if(
 (<+...
- rcu_dereference
+ rcu_access_pointer
  (...)
  ...+>)) {...}
|
 while(
 (<+...
- rcu_dereference
+ rcu_access_pointer
  (...)
  ...+>)) {...}
)

Signed-off-by: Andreea-Cristina Bernat <bernat.ada-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 net/mac80211/mesh_pathtbl.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/mac80211/mesh_pathtbl.c b/net/mac80211/mesh_pathtbl.c
index cf032a8..a6699dc 100644
--- a/net/mac80211/mesh_pathtbl.c
+++ b/net/mac80211/mesh_pathtbl.c
@@ -729,7 +729,7 @@ void mesh_plink_broken(struct sta_info *sta)
 	tbl = rcu_dereference(mesh_paths);
 	for_each_mesh_entry(tbl, node, i) {
 		mpath = node->mpath;
-		if (rcu_dereference(mpath->next_hop) == sta &&
+		if (rcu_access_pointer(mpath->next_hop) == sta &&
 		    mpath->flags & MESH_PATH_ACTIVE &&
 		    !(mpath->flags & MESH_PATH_FIXED)) {
 			spin_lock_bh(&mpath->state_lock);
@@ -794,7 +794,7 @@ void mesh_path_flush_by_nexthop(struct sta_info *sta)
 	tbl = resize_dereference_mesh_paths();
 	for_each_mesh_entry(tbl, node, i) {
 		mpath = node->mpath;
-		if (rcu_dereference(mpath->next_hop) == sta) {
+		if (rcu_access_pointer(mpath->next_hop) == sta) {
 			spin_lock(&tbl->hashwlock[i]);
 			__mesh_path_del(tbl, node);
 			spin_unlock(&tbl->hashwlock[i]);
-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
