From: SF Markus Elfring <elfring@users.sourceforge.net>
Subject: [PATCH] flowcache: Delete an error message for a failed memory
 allocation in flow_cache_cpu_prepare()
Date: Mon, 22 May 2017 09:33:07 +0200
Message-ID: <308bd3f5-d4f8-068b-7110-f9499ea7624e@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Language: en-GB
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Markus Elfring <elfring@users.sourceforge.net>
Date: Mon, 22 May 2017 09:19:51 +0200

Omit an extra message for a memory allocation failure in this function.

This issue was detected by using the Coccinelle software.

Link: http://events.linuxfoundation.org/sites/events/files/slides/LCJ16-Refactor_Strings-WSang_0.pdf
Signed-off-by: Markus Elfring <elfring@users.sourceforge.net>
---
 net/core/flow.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/core/flow.c b/net/core/flow.c
index f7f5d1932a27..08c851236b97 100644
--- a/net/core/flow.c
+++ b/net/core/flow.c
@@ -412,7 +412,6 @@ static int flow_cache_cpu_prepare(struct flow_cache *fc, int cpu)
-		if (!fcp->hash_table) {
-			pr_err("NET: failed to allocate flow cache sz %u\n", sz);
+		if (!fcp->hash_table)
 			return -ENOMEM;
-		}
+
 		fcp->hash_rnd_recalc = 1;
 		fcp->hash_count = 0;
 		tasklet_init(&fcp->flush_tasklet, flow_cache_flush_tasklet, 0);
-- 
2.13.0
