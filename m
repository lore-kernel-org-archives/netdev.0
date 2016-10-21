From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 01/13] netfilter: xt_hashlimit: Add missing ULL suffixes for 64-bit constants
Date: Fri, 21 Oct 2016 12:12:11 +0200
Message-ID: <1477044743-18948-2-git-send-email-pablo@netfilter.org>
References: <1477044743-18948-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:36284 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754853AbcJUKMn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 21 Oct 2016 06:12:43 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id C5AD626E0D
        for <netdev@vger.kernel.org>; Fri, 21 Oct 2016 12:12:41 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id B2C6DBAC30
        for <netdev@vger.kernel.org>; Fri, 21 Oct 2016 12:12:41 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 0EB33BAC27
        for <netdev@vger.kernel.org>; Fri, 21 Oct 2016 12:12:36 +0200 (CEST)
In-Reply-To: <1477044743-18948-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Geert Uytterhoeven <geert@linux-m68k.org>

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
Acked-by: Vishwanath Pai <vpai@akamai.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_hashlimit.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/xt_hashlimit.c b/net/netfilter/xt_hashlimit.c
index 2fab0c65aa94..b89b688e9d01 100644
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
2.1.4
