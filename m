From: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>
Subject: [PATCH 5/7][MAC80211]: Do not report false error from mesh_path_add.
Date: Wed, 07 May 2008 19:54:04 +0400
Message-ID: <4821D09C.2010100@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

In case the hash grow failed, it is not fair to return error -
the new node _was_ _actually_ added in this case.

Besides, after my previous patch, this grow is more likely
to fail on large hashes.

Signed-off-by: Pavel Emelyanov <xemul-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>

---
 net/mac80211/mesh_pathtbl.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/mac80211/mesh_pathtbl.c b/net/mac80211/mesh_pathtbl.c
index 1154398..947b13b 100644
--- a/net/mac80211/mesh_pathtbl.c
+++ b/net/mac80211/mesh_pathtbl.c
@@ -206,7 +206,7 @@ int mesh_path_add(u8 *dst, struct net_device *dev)
 		newtbl = mesh_table_grow(mesh_paths);
 		if (!newtbl) {
 			write_unlock(&pathtbl_resize_lock);
-			return -ENOMEM;
+			return 0;
 		}
 		rcu_assign_pointer(mesh_paths, newtbl);
 		write_unlock(&pathtbl_resize_lock);
-- 
1.5.3.4

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
