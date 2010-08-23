From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the final tree (net tree
 related)
Date: Mon, 23 Aug 2010 13:27:34 +1000
Message-ID: <20100823132734.ffc076ae.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	=?UTF-8?B?Ikdyw6lnb2lyZSBCYXJvbiI=?= <baronchon@n7mm.org>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

After merging the final tree, today's linux-next build (powerpc
allyesconfig) failed like this:

net/sched/act_csum.c: In function 'tcf_csum_ipv6_icmp':
net/sched/act_csum.c:178: error: implicit declaration of function 'csum_ipv6_magic'

Caused by commit eb4d40654505e47aa9d2035bb97f631fa61d14b4 ("net/sched:
add ACT_CSUM action to update packets checksums").

I added this patch for today:

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Mon, 23 Aug 2010 13:23:22 +1000
Subject: [PATCH] net/sched: need to include net/ip6_checksum.h

for the declararion of csum_ipv6_magic.

Fixes this build error on PowerPC (at least):

net/sched/act_csum.c: In function 'tcf_csum_ipv6_icmp':
net/sched/act_csum.c:178: error: implicit declaration of function 'csum_ipv6_magic'

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 net/sched/act_csum.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/sched/act_csum.c b/net/sched/act_csum.c
index 58d7f36..be41f1c 100644
--- a/net/sched/act_csum.c
+++ b/net/sched/act_csum.c
@@ -29,6 +29,7 @@
 #include <linux/igmp.h>
 #include <net/tcp.h>
 #include <net/udp.h>
+#include <net/ip6_checksum.h>
 
 #include <net/act_api.h>
 
-- 
1.7.1

-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/
