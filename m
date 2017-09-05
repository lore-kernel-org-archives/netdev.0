From: Vishwanath Pai <vpai@akamai.com>
Subject: [PATCH] netfilter: xt_hashlimit: fix 64 bit division compile error
Date: Mon,  4 Sep 2017 21:03:27 -0400
Message-ID: <1504573407-26293-1-git-send-email-vpai@akamai.com>
Cc: johunt@akamai.com, fw@strlen.de, netdev@vger.kernel.org,
        pai.vishwain@gmail.com
To: pablo@netfilter.org, kadlec@blackhole.kfki.hu,
        netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit bea74641e378 ("netfilter: xt_hashlimit: add rate match mode")
introduced a line where we divide two 64bit unsigned integers. This
breaks on ARM processors with the error:

ERROR: "__aeabi_uldivmod" [net/netfilter/xt_hashlimit.ko] undefined!

We can fix it by using div64_u64 instead.

Fixes: bea74641e378 ("netfilter: xt_hashlimit: add rate match mode")
Signed-off-by: Vishwanath Pai <vpai@akamai.com>
---
 net/netfilter/xt_hashlimit.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/xt_hashlimit.c b/net/netfilter/xt_hashlimit.c
index 10d4823..fece7c2 100644
--- a/net/netfilter/xt_hashlimit.c
+++ b/net/netfilter/xt_hashlimit.c
@@ -531,7 +531,7 @@ static u64 user2rate_bytes(u64 user)
 {
 	u64 r;
 
-	r = user ? 0xFFFFFFFFULL / user : 0xFFFFFFFFULL;
+	r = user ? div64_u64(0xFFFFFFFFULL, user) : 0xFFFFFFFFULL;
 	r = (r - 1) << 4;
 	return r;
 }
-- 
1.9.1

