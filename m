From: Shan Wei <shanwei88@gmail.com>
Subject: [PATCH v3 3/9] net: xfrm: use __this_cpu_read per-cpu helper
Date: Fri, 09 Nov 2012 10:20:59 +0800
Message-ID: <509C688B.5010502@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: steffen.klassert@secunet.com, David Miller <davem@davemloft.net>,
	NetDev <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Kernel-Maillist <linux-kernel@vger.kernel.org>,
	cl@linux-foundation.org, Shan Wei <shanwei88@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Shan Wei <davidshan@tencent.com>


Signed-off-by: Shan Wei <davidshan@tencent.com>
---
v3 fix compile warning:
net/xfrm/xfrm_ipcomp.c: In function 'ipcomp_alloc_tfms':
net/xfrm/xfrm_ipcomp.c:285: warning: assignment from incompatible pointer type

---
 net/xfrm/xfrm_ipcomp.c |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/net/xfrm/xfrm_ipcomp.c b/net/xfrm/xfrm_ipcomp.c
index e5246fb..898c899 100644
--- a/net/xfrm/xfrm_ipcomp.c
+++ b/net/xfrm/xfrm_ipcomp.c
@@ -276,18 +276,15 @@ static struct crypto_comp * __percpu *ipcomp_alloc_tfms(const char *alg_name)
 	struct crypto_comp * __percpu *tfms;
 	int cpu;
 
-	/* This can be any valid CPU ID so we don't need locking. */
-	cpu = raw_smp_processor_id();
 
 	list_for_each_entry(pos, &ipcomp_tfms_list, list) {
 		struct crypto_comp *tfm;
 
-		tfms = pos->tfms;
-		tfm = *per_cpu_ptr(tfms, cpu);
+		tfm = (struct crypto_comp *) __this_cpu_read(pos->tfms);
 
 		if (!strcmp(crypto_comp_name(tfm), alg_name)) {
 			pos->users++;
-			return tfms;
+			return pos->tfms;
 		}
 	}
 
-- 
1.7.1
