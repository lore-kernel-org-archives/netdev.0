From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH v3.6 06/19] batman-adv: use batadv_compare_eth for concise
Date: Wed, 8 Jan 2014 10:53:29 +0800
Message-ID: <52CCBDA9.8090205@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Marek Lindner <mareklindner@neomailbox.ch>,
	Simon Wunderlich <sw@simonwunderlich.de>,
	Antonio Quartulli <antonio@meshcoding.com>,
	"David S. Miller" <davem@davemloft.net>,
	<b.a.t.m.a.n@lists.open-mesh.org>, Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:43018 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754968AbaAHCx5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jan 2014 21:53:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is better to use batadv_compate_eth instead of memcpy for
concise style.

Cc: Marek Lindner <mareklindner@neomailbox.ch>
Cc: Simon Wunderlich <sw@simonwunderlich.de>
Cc: Antonio Quartulli <antonio@meshcoding.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: b.a.t.m.a.n@lists.open-mesh.org
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
Signed-off-by: Tan Xiaojun <tanxiaojun@huawei.com>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
Acked-by: Antonio Quartulli <antonio@meshcoding.com>
---
 net/batman-adv/originator.c        | 2 +-
 net/batman-adv/translation-table.c | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/batman-adv/originator.c b/net/batman-adv/originator.c
index 8ab1434..803ab4b 100644
--- a/net/batman-adv/originator.c
+++ b/net/batman-adv/originator.c
@@ -41,7 +41,7 @@ int batadv_compare_orig(const struct hlist_node *node, const void *data2)
 	const void *data1 = container_of(node, struct batadv_orig_node,
 					 hash_entry);
 
-	return (memcmp(data1, data2, ETH_ALEN) == 0 ? 1 : 0);
+	return batadv_compare_eth(data1, data2);
 }
 
 /**
diff --git a/net/batman-adv/translation-table.c b/net/batman-adv/translation-table.c
index 4add57d..06506e6 100644
--- a/net/batman-adv/translation-table.c
+++ b/net/batman-adv/translation-table.c
@@ -51,7 +51,7 @@ static int batadv_compare_tt(const struct hlist_node *node, const void *data2)
 	const void *data1 = container_of(node, struct batadv_tt_common_entry,
 					 hash_entry);
 
-	return (memcmp(data1, data2, ETH_ALEN) == 0 ? 1 : 0);
+	return batadv_compare_eth(data1, data2);
 }
 
 /**
-- 
1.8.0
