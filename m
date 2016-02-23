From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 13/20] batman-adv: Rename batadv_tvlv_container *_free_ref function to *_put
Date: Tue, 23 Feb 2016 14:08:16 +0800
Message-ID: <1456207703-903-14-git-send-email-a@unstable.cc>
References: <1456207703-903-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:5478 "EHLO s2.neomailbox.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757025AbcBWGVw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Feb 2016 01:21:52 -0500
In-Reply-To: <1456207703-903-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

The batman-adv source code is the only place in the kernel which uses the
*_free_ref naming scheme for the *_put functions. Changing it to *_put
makes it more consistent and makes it easier to understand the connection
to the *_get functions.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <a@unstable.cc>
---
 net/batman-adv/main.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index 95aaff371966..bf8a01b8f026 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -694,11 +694,11 @@ static void batadv_tvlv_container_release(struct kref *ref)
 }
 
 /**
- * batadv_tvlv_container_free_ref - decrement the tvlv container refcounter and
+ * batadv_tvlv_container_put - decrement the tvlv container refcounter and
  *  possibly release it
  * @tvlv: the tvlv container to free
  */
-static void batadv_tvlv_container_free_ref(struct batadv_tvlv_container *tvlv)
+static void batadv_tvlv_container_put(struct batadv_tvlv_container *tvlv)
 {
 	kref_put(&tvlv->refcount, batadv_tvlv_container_release);
 }
@@ -784,8 +784,8 @@ static void batadv_tvlv_container_remove(struct batadv_priv *bat_priv,
 	hlist_del(&tvlv->list);
 
 	/* first call to decrement the counter, second call to free */
-	batadv_tvlv_container_free_ref(tvlv);
-	batadv_tvlv_container_free_ref(tvlv);
+	batadv_tvlv_container_put(tvlv);
+	batadv_tvlv_container_put(tvlv);
 }
 
 /**
-- 
2.7.1
