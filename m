From: Andrzej Hajda <a.hajda@samsung.com>
Subject: [PATCH v2 18/19] mac80211: make ieee80211_new_mesh_header return
 unsigned
Date: Fri, 25 Sep 2015 08:42:00 +0200
Message-ID: <1443163320-25593-1-git-send-email-a.hajda@samsung.com>
References: <1443103799.1869.6.camel@sipsolutions.net>
Cc: Andrzej Hajda <a.hajda@samsung.com>,
	Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>,
	Marek Szyprowski <m.szyprowski@samsung.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <1443103799.1869.6.camel@sipsolutions.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The function returns always non-negative values.

The problem has been detected using proposed semantic patch
scripts/coccinelle/tests/assign_signed_to_unsigned.cocci [1].

[1]: http://permalink.gmane.org/gmane.linux.kernel/2046107

Signed-off-by: Andrzej Hajda <a.hajda@samsung.com>
---
v2: added missing declaration change, fixed indentation
---
 net/mac80211/mesh.c | 6 +++---
 net/mac80211/mesh.h | 6 +++---
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/mac80211/mesh.c b/net/mac80211/mesh.c
index e06a5ca..90567fc 100644
--- a/net/mac80211/mesh.c
+++ b/net/mac80211/mesh.c
@@ -540,9 +540,9 @@ int ieee80211_fill_mesh_addresses(struct ieee80211_hdr *hdr, __le16 *fc,
  *
  * Return the header length.
  */
-int ieee80211_new_mesh_header(struct ieee80211_sub_if_data *sdata,
-			      struct ieee80211s_hdr *meshhdr,
-			      const char *addr4or5, const char *addr6)
+unsigned int ieee80211_new_mesh_header(struct ieee80211_sub_if_data *sdata,
+				       struct ieee80211s_hdr *meshhdr,
+				       const char *addr4or5, const char *addr6)
 {
 	if (WARN_ON(!addr4or5 && addr6))
 		return 0;
diff --git a/net/mac80211/mesh.h b/net/mac80211/mesh.h
index 50c8473..029e41d 100644
--- a/net/mac80211/mesh.h
+++ b/net/mac80211/mesh.h
@@ -207,9 +207,9 @@ struct mesh_rmc {
 /* Various */
 int ieee80211_fill_mesh_addresses(struct ieee80211_hdr *hdr, __le16 *fc,
 				  const u8 *da, const u8 *sa);
-int ieee80211_new_mesh_header(struct ieee80211_sub_if_data *sdata,
-			      struct ieee80211s_hdr *meshhdr,
-			      const char *addr4or5, const char *addr6);
+unsigned int ieee80211_new_mesh_header(struct ieee80211_sub_if_data *sdata,
+				       struct ieee80211s_hdr *meshhdr,
+				       const char *addr4or5, const char *addr6);
 int mesh_rmc_check(struct ieee80211_sub_if_data *sdata,
 		   const u8 *addr, struct ieee80211s_hdr *mesh_hdr);
 bool mesh_matches_local(struct ieee80211_sub_if_data *sdata,
-- 
1.9.1
