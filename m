From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 03/21] batman-adv: Add lockdep assert for container_list_lock
Date: Wed, 10 Feb 2016 23:57:09 +0800
Message-ID: <1455119847-5862-4-git-send-email-a@unstable.cc>
References: <1455119847-5862-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <mareklindner@neomailbox.ch>,
	Antonio Quartulli <a@unstable.cc>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:4261 "EHLO s2.neomailbox.net"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752249AbcBJQAB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Feb 2016 11:00:01 -0500
In-Reply-To: <1455119847-5862-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sven Eckelmann <sven@narfation.org>

The batadv_tvlv_container* functions state in their kernel-doc that they
require tvlv.container_list_lock. Add an assert to automatically detect
when this might have been ignored by the caller.

Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
Signed-off-by: Antonio Quartulli <a@unstable.cc>
---
 net/batman-adv/main.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/batman-adv/main.c b/net/batman-adv/main.c
index 5f319fd6ecd7..a9b4f75db874 100644
--- a/net/batman-adv/main.c
+++ b/net/batman-adv/main.c
@@ -697,6 +697,8 @@ static struct batadv_tvlv_container
 {
 	struct batadv_tvlv_container *tvlv_tmp, *tvlv = NULL;
 
+	lockdep_assert_held(&bat_priv->tvlv.container_list_lock);
+
 	hlist_for_each_entry(tvlv_tmp, &bat_priv->tvlv.container_list, list) {
 		if (tvlv_tmp->tvlv_hdr.type != type)
 			continue;
@@ -729,6 +731,8 @@ static u16 batadv_tvlv_container_list_size(struct batadv_priv *bat_priv)
 	struct batadv_tvlv_container *tvlv;
 	u16 tvlv_len = 0;
 
+	lockdep_assert_held(&bat_priv->tvlv.container_list_lock);
+
 	hlist_for_each_entry(tvlv, &bat_priv->tvlv.container_list, list) {
 		tvlv_len += sizeof(struct batadv_tvlv_hdr);
 		tvlv_len += ntohs(tvlv->tvlv_hdr.len);
-- 
2.7.1
