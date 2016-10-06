From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH] netfilter: xt_hashlimit: Add missing ULL suffixes for 64-bit constants
Date: Thu,  6 Oct 2016 15:40:14 +0200
Message-ID: <1475761214-13387-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Geert Uytterhoeven <geert@linux-m68k.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>,
        Patrick McHardy <kaber@trash.net>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        "David S. Miller" <davem@davemloft.net>,
        Vishwanath Pai <vpai@akamai.com>,
        Joshua Hunt <johunt@akamai.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 32-bit (e.g. with m68k-linux-gnu-gcc-4.1):

    net/netfilter/xt_hashlimit.c: In function ‘user2credits’:
    net/netfilter/xt_hashlimit.c:476: warning: integer constant is too large for ‘long’ type
    ...
    net/netfilter/xt_hashlimit.c:478: warning: integer constant is too large for ‘long’ type
    ...
    net/netfilter/xt_hashlimit.c:480: warning: integer constant is too large for ‘long’ type
    ...

    net/netfilter/xt_hashlimit.c: In function ‘rateinfo_recalc’:
    net/netfilter/xt_hashlimit.c:513: warning: integer constant is too large for ‘long’ type

Fixes: 11d5f15723c9f39d ("netfilter: xt_hashlimit: Create revision 2 to support higher pps rates")
Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
 net/netfilter/xt_hashlimit.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/xt_hashlimit.c b/net/netfilter/xt_hashlimit.c
index 2fab0c65aa94b666..b89b688e9d01a2d1 100644
--- a/net/netfilter/xt_hashlimit.c
+++ b/net/netfilter/xt_hashlimit.c
@@ -431,7 +431,7 @@ static void htable_put(struct xt_hashlimit_htable *hinfo)
    CREDITS_PER_JIFFY*HZ*60*60*24 < 2^32 ie.
 */
 #define MAX_CPJ_v1 (0xFFFFFFFF / (HZ*60*60*24))
-#define MAX_CPJ (0xFFFFFFFFFFFFFFFF / (HZ*60*60*24))
+#define MAX_CPJ (0xFFFFFFFFFFFFFFFFULL / (HZ*60*60*24))
 
 /* Repeated shift and or gives us all 1s, final shift and add 1 gives
  * us the power of 2 below the theoretical max, so GCC simply does a
@@ -473,7 +473,7 @@ static u64 user2credits(u64 user, int revision)
 		return div64_u64(user * HZ * CREDITS_PER_JIFFY_v1,
 				 XT_HASHLIMIT_SCALE);
 	} else {
-		if (user > 0xFFFFFFFFFFFFFFFF / (HZ*CREDITS_PER_JIFFY))
+		if (user > 0xFFFFFFFFFFFFFFFFULL / (HZ*CREDITS_PER_JIFFY))
 			return div64_u64(user, XT_HASHLIMIT_SCALE_v2)
 				* HZ * CREDITS_PER_JIFFY;
 
-- 
1.9.1
