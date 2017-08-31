From: Thomas Meyer <thomas@m3y3r.de>
Subject: [PATCH] ipv6: sr: Use ARRAY_SIZE macro
Date: Thu, 31 Aug 2017 16:18:15 +0200
Message-ID: <20170831141815.28003-1-thomas@m3y3r.de>
Cc: Thomas Meyer <thomas@m3y3r.de>
To: davem@davemloft.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Grepping for "sizeof\(.+\) / sizeof\(" found this as one of the first
candidates.
Maybe a coccinelle can catch all of those.

Signed-off-by: Thomas Meyer <thomas@m3y3r.de>
---
 net/ipv6/seg6_hmac.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/ipv6/seg6_hmac.c b/net/ipv6/seg6_hmac.c
index f950cb53d5e3..33fb35cbfac1 100644
--- a/net/ipv6/seg6_hmac.c
+++ b/net/ipv6/seg6_hmac.c
@@ -12,6 +12,7 @@
  */
 
 #include <linux/errno.h>
+#include <linux/kernel.h>
 #include <linux/types.h>
 #include <linux/socket.h>
 #include <linux/sockios.h>
@@ -110,7 +111,7 @@ static struct seg6_hmac_algo *__hmac_get_algo(u8 alg_id)
 	struct seg6_hmac_algo *algo;
 	int i, alg_count;
 
-	alg_count = sizeof(hmac_algos) / sizeof(struct seg6_hmac_algo);
+	alg_count = ARRAY_SIZE(hmac_algos);
 	for (i = 0; i < alg_count; i++) {
 		algo = &hmac_algos[i];
 		if (algo->alg_id == alg_id)
@@ -360,7 +361,7 @@ static int seg6_hmac_init_algo(void)
 	struct shash_desc *shash;
 	int i, alg_count, cpu;
 
-	alg_count = sizeof(hmac_algos) / sizeof(struct seg6_hmac_algo);
+	alg_count = ARRAY_SIZE(hmac_algos);
 
 	for (i = 0; i < alg_count; i++) {
 		struct crypto_shash **p_tfm;
@@ -421,7 +422,7 @@ void seg6_hmac_exit(void)
 	struct seg6_hmac_algo *algo = NULL;
 	int i, alg_count, cpu;
 
-	alg_count = sizeof(hmac_algos) / sizeof(struct seg6_hmac_algo);
+	alg_count = ARRAY_SIZE(hmac_algos);
 	for (i = 0; i < alg_count; i++) {
 		algo = &hmac_algos[i];
 		for_each_possible_cpu(cpu) {
-- 
2.11.0
