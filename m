From: akpm@linux-foundation.org
Subject: [patch 1/2] net/tipc/bcast.h: use ARRAY_SIZE
Date: Fri, 09 Jan 2009 12:22:21 -0800
Message-ID: <200901092022.n09KMLkf019501@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org, julia@diku.dk,
	per.liden@nospam.ericsson.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:52505 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754565AbZAIUW6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2009 15:22:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia@diku.dk>

ARRAY_SIZE is more concise to use when the size of an array is divided by
the size of its type or the size of its first element.

The semantic patch that makes this change is as follows:
(http://www.emn.fr/x-info/coccinelle/)

// <smpl>
@i@
@@

#include <linux/kernel.h>

@depends on i using "paren.iso"@
type T;
T[] E;
@@

- (sizeof(E)/sizeof(T))
+ ARRAY_SIZE(E)
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>
Cc: Per Liden <per.liden@nospam.ericsson.com>
Cc: David S. Miller <davem@davemloft.net>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 net/tipc/bcast.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN net/tipc/bcast.h~net-tipc-bcasth-use-array_size net/tipc/bcast.h
--- a/net/tipc/bcast.h~net-tipc-bcasth-use-array_size
+++ a/net/tipc/bcast.h
@@ -124,7 +124,7 @@ static inline int tipc_nmap_equal(struct
 static inline void tipc_nmap_diff(struct tipc_node_map *nm_a, struct tipc_node_map *nm_b,
 				  struct tipc_node_map *nm_diff)
 {
-	int stop = sizeof(nm_a->map) / sizeof(u32);
+	int stop = ARRAY_SIZE(nm_a->map);
 	int w;
 	int b;
 	u32 map;
_
