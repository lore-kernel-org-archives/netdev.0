From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build failure after merge of the final tree
 (net-next tree related)
Date: Mon, 30 Apr 2012 13:22:03 -0400 (EDT)
Message-ID: <20120430.132203.912342595853741106.davem@davemloft.net>
References: <20120430155836.44bcf3846c80cf686bb9cb77@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, bcrl@kvack.org
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20120430155836.44bcf3846c80cf686bb9cb77@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Mon, 30 Apr 2012 15:58:36 +1000

> Hi all,
> 
> After merging the final tree, today's linux-next build (powerpc
> allyesconfig) failed like this:
> 
> net/l2tp/l2tp_core.c: In function 'l2tp_verify_udp_checksum':
> net/l2tp/l2tp_core.c:464:7: error: implicit declaration of function 'csum_ipv6_magic' [-Werror=implicit-function-declaration]
> 
> Caused by commit d2cf3361677e ("net/l2tp: add support for L2TP over IPv6
> UDP").  Include file missing.
> 
> I have reverted that commit for today.

The fix is less work than the revert on this one isn't it? :-)

Pushed to net-next, thanks Stephen:

--------------------
l2tp: Add missing net/net/ip6_checksum.h include.

Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/l2tp/l2tp_core.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index e91d559..0ca9bc3 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -56,6 +56,7 @@
 #include <net/inet6_connection_sock.h>
 #include <net/inet_ecn.h>
 #include <net/ip6_route.h>
+#include <net/ip6_checksum.h>
 
 #include <asm/byteorder.h>
 #include <linux/atomic.h>
-- 
1.7.7.6
