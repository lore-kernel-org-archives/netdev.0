From: Shan Wei <shanwei88@gmail.com>
Subject: [PATCH 3/9] net: xfrm: use this_cpu_ptr per-cpu helper
Date: Wed, 31 Oct 2012 19:22:33 +0800
Message-ID: <509109F9.3030904@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: steffen.klassert@secunet.com, David Miller <davem@davemloft.net>,
	NetDev <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Kernel-Maillist <linux-kernel@vger.kernel.org>,
	cl@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Shan Wei <davidshan@tencent.com>


Signed-off-by: Shan Wei <davidshan@tencent.com>
---
 net/xfrm/xfrm_ipcomp.c |    7 +++----
 1 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/net/xfrm/xfrm_ipcomp.c b/net/xfrm/xfrm_ipcomp.c
index e5246fb..af6c78a 100644
--- a/net/xfrm/xfrm_ipcomp.c
+++ b/net/xfrm/xfrm_ipcomp.c
@@ -276,14 +276,13 @@ static struct crypto_comp * __percpu *ipcomp_alloc_tfms(const char *alg_name)
 	struct crypto_comp * __percpu *tfms;
 	int cpu;
 
-	/* This can be any valid CPU ID so we don't need locking. */
-	cpu = raw_smp_processor_id();
-
 	list_for_each_entry(pos, &ipcomp_tfms_list, list) {
 		struct crypto_comp *tfm;
 
 		tfms = pos->tfms;
-		tfm = *per_cpu_ptr(tfms, cpu);
+
+		/* This can be any valid CPU ID so we don't need locking. */
+		tfm = *this_cpu_ptr(tfms);
 
 		if (!strcmp(crypto_comp_name(tfm), alg_name)) {
 			pos->users++;
-- 
1.7.1
