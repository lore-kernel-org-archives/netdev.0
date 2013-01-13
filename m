From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 01/15] batman-adv: use per_cpu_add helper
Date: Mon, 14 Jan 2013 09:41:06 +1000
Message-ID: <1358120480-25960-2-git-send-email-ordex@autistici.org>
References: <1358120480-25960-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Shan Wei <davidshan@tencent.com>,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <lindner_marek@yahoo.de>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from diserzione.investici.org ([82.221.99.153]:49340 "EHLO
	diserzione.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755309Ab3AMXm0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jan 2013 18:42:26 -0500
In-Reply-To: <1358120480-25960-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shan Wei <davidshan@tencent.com>

this_cpu_add is an atomic operation.
and be more faster than per_cpu_ptr operation.

Signed-off-by: Shan Wei <davidshan@tencent.com>
Reviewed-by: Christoph Lameter <cl@linux.com>
Signed-off-by: Sven Eckelmann <sven@narfation.org>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/main.h | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index 2f85577..c4fe41f 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -276,9 +276,7 @@ static inline bool batadv_has_timed_out(unsigned long timestamp,
 static inline void batadv_add_counter(struct batadv_priv *bat_priv, size_t idx,
 				      size_t count)
 {
-	int cpu = get_cpu();
-	per_cpu_ptr(bat_priv->bat_counters, cpu)[idx] += count;
-	put_cpu();
+	this_cpu_add(bat_priv->bat_counters[idx], count);
 }
 
 #define batadv_inc_counter(b, i) batadv_add_counter(b, i, 1)
-- 
1.8.0.2
