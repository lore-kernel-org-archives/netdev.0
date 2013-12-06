From: Joe Perches <joe@perches.com>
Subject: [PATCH -next] batadv: Slight optimization of batadv_compare_eth
Date: Fri, 06 Dec 2013 00:18:10 -0800
Message-ID: <1386317890.31845.26.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	b.a.t.m.a.n@lists.open-mesh.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Marek Lindner <mareklindner@neomailbox.ch>,
	Simon Wunderlich <sw@simonwunderlich.de>,
	Antonio Quartulli <antonio@meshcoding.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS to check if
this function can be optimized by using the generic
ether_addr_equal.

Remove the unnecessary ?: after the unoptimized memcmp.

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/batman-adv/main.h | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index f94f287b..74a7a3f 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -266,7 +266,11 @@ static inline void batadv_dbg(int type __always_unused,
  */
 static inline int batadv_compare_eth(const void *data1, const void *data2)
 {
-	return (memcmp(data1, data2, ETH_ALEN) == 0 ? 1 : 0);
+#if defined(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS)
+	return ether_addr_equal(data1, data2);
+#else
+	return memcmp(data1, data2, ETH_ALEN) == 0;
+#endif
 }
 
 /**
