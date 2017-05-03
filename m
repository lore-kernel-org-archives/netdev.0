From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH] netfilter: conntrack: Force inlining of build check to prevent build failure
Date: Wed,  3 May 2017 14:18:43 +0200
Message-ID: <1493813923-5441-1-git-send-email-geert@linux-m68k.org>
Cc: Arnd Bergmann <arnd@arndb.de>, netfilter-devel@vger.kernel.org,
        coreteam@netfilter.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Geert Uytterhoeven <geert@linux-m68k.org>
To: "David S . Miller" <davem@davemloft.net>,
        Florian Westphal <fw@strlen.de>,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If gcc (e.g. 4.1.2) decides not to inline total_extension_size(), the
build will fail with:

    net/built-in.o: In function `nf_conntrack_init_start':
    (.text+0x9baf6): undefined reference to `__compiletime_assert_1893'

or

    ERROR: "__compiletime_assert_1893" [net/netfilter/nf_conntrack.ko] undefined!

Fix this by forcing inlining of total_extension_size().

Fixes: b3a5db109e0670d6 ("netfilter: conntrack: use u8 for extension sizes again")
Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
 net/netfilter/nf_conntrack_core.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index f9245dbfe4356da6..3c8f1ed2f5558fe0 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1853,7 +1853,7 @@ EXPORT_SYMBOL_GPL(nf_conntrack_set_hashsize);
 module_param_call(hashsize, nf_conntrack_set_hashsize, param_get_uint,
 		  &nf_conntrack_htable_size, 0600);
 
-static unsigned int total_extension_size(void)
+static __always_inline unsigned int total_extension_size(void)
 {
 	/* remember to add new extensions below */
 	BUILD_BUG_ON(NF_CT_EXT_NUM > 9);
-- 
2.7.4

