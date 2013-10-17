From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next v3 9/9] net: switch net_secret key generation to net_get_random_once
Date: Thu, 17 Oct 2013 07:32:03 +0200
Message-ID: <1381987923-1524-10-git-send-email-hannes@stressinduktion.org>
References: <1381987923-1524-1-git-send-email-hannes@stressinduktion.org>
Cc: linux-kernel@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1381987923-1524-1-git-send-email-hannes@stressinduktion.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Cc: Eric Dumazet <edumazet@google.com>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/core/secure_seq.c | 14 ++------------
 1 file changed, 2 insertions(+), 12 deletions(-)

diff --git a/net/core/secure_seq.c b/net/core/secure_seq.c
index 3f1ec15..b02fd16 100644
--- a/net/core/secure_seq.c
+++ b/net/core/secure_seq.c
@@ -7,6 +7,7 @@
 #include <linux/hrtimer.h>
 #include <linux/ktime.h>
 #include <linux/string.h>
+#include <linux/net.h>
 
 #include <net/secure_seq.h>
 
@@ -16,18 +17,7 @@ static u32 net_secret[NET_SECRET_SIZE] ____cacheline_aligned;
 
 static void net_secret_init(void)
 {
-	u32 tmp;
-	int i;
-
-	if (likely(net_secret[0]))
-		return;
-
-	for (i = NET_SECRET_SIZE; i > 0;) {
-		do {
-			get_random_bytes(&tmp, sizeof(tmp));
-		} while (!tmp);
-		cmpxchg(&net_secret[--i], 0, tmp);
-	}
+	net_get_random_once(net_secret, sizeof(net_secret));
 }
 
 #ifdef CONFIG_INET
-- 
1.8.3.1
