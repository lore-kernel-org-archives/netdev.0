From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 3/7][MAC80211]: Report allocation failure from mesh_path_node_copy.
Date: Wed, 07 May 2008 19:48:14 +0400
Message-ID: <4821CF3E.1050301@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:46638 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756533AbYEGPvC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 May 2008 11:51:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now - return the -ENOMEM in case kmalloc fails.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 net/mac80211/mesh_pathtbl.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/net/mac80211/mesh_pathtbl.c b/net/mac80211/mesh_pathtbl.c
index 512bfa1..fe1ceee 100644
--- a/net/mac80211/mesh_pathtbl.c
+++ b/net/mac80211/mesh_pathtbl.c
@@ -469,9 +469,12 @@ static int mesh_path_node_copy(struct hlist_node *p, struct mesh_table *newtbl)
 	struct mpath_node *node, *new_node;
 	u32 hash_idx;
 
+	new_node = kmalloc(sizeof(struct mpath_node), GFP_KERNEL);
+	if (new_node == NULL)
+		return -ENOMEM;
+
 	node = hlist_entry(p, struct mpath_node, list);
 	mpath = node->mpath;
-	new_node = kmalloc(sizeof(struct mpath_node), GFP_KERNEL);
 	new_node->mpath = mpath;
 	hash_idx = mesh_table_hash(mpath->dst, mpath->dev, newtbl);
 	hlist_add_head(&new_node->list,
-- 
1.5.3.4

