From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: change default tcp hash size
Date: Fri, 30 Nov 2012 12:08:52 -0800
Message-ID: <1354306132.20109.41.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:51716 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751398Ab2K3UIy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Nov 2012 15:08:54 -0500
Received: by mail-pa0-f46.google.com with SMTP id bh2so578603pad.19
        for <netdev@vger.kernel.org>; Fri, 30 Nov 2012 12:08:54 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

As time passed, available memory increased faster than number of
concurrent tcp sockets. 

As a result, a machine with 4GB of ram gets a hash table
with 524288 slots, using 8388608 bytes of memory.

Lets change that by a 16x factor (one slot for 128 KB of ram)

Even if a small machine needs a _lot_ of sockets, tcp lookups are now
very efficient, using one cache line per socket.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp.c |    6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index e6eace1..1aca02c 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -3590,8 +3590,7 @@ void __init tcp_init(void)
 		alloc_large_system_hash("TCP established",
 					sizeof(struct inet_ehash_bucket),
 					thash_entries,
-					(totalram_pages >= 128 * 1024) ?
-					13 : 15,
+					17, /* one slot per 128 KB of memory */
 					0,
 					NULL,
 					&tcp_hashinfo.ehash_mask,
@@ -3607,8 +3606,7 @@ void __init tcp_init(void)
 		alloc_large_system_hash("TCP bind",
 					sizeof(struct inet_bind_hashbucket),
 					tcp_hashinfo.ehash_mask + 1,
-					(totalram_pages >= 128 * 1024) ?
-					13 : 15,
+					17, /* one slot per 128 KB of memory */
 					0,
 					&tcp_hashinfo.bhash_size,
 					NULL,
