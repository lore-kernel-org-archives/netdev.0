From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: ping: small changes
Date: Sat, 14 May 2011 10:59:19 +0200
Message-ID: <1305363559.3120.54.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Vasiliy Kulikov <segoon@openwall.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:62659 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752014Ab1ENI7Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 May 2011 04:59:24 -0400
Received: by wwa36 with SMTP id 36so3590850wwa.1
        for <netdev@vger.kernel.org>; Sat, 14 May 2011 01:59:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ping_table is not __read_mostly, since it contains one rwlock,
and is static to ping.c

ping_port_rover & ping_v4_lookup are static

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Vasiliy Kulikov <segoon@openwall.com>
---
 net/ipv4/ping.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/ping.c b/net/ipv4/ping.c
index a77e2d7..7041d09 100644
--- a/net/ipv4/ping.c
+++ b/net/ipv4/ping.c
@@ -49,9 +49,9 @@
 #include <net/checksum.h>
 
 
-struct ping_table ping_table __read_mostly;
+static struct ping_table ping_table;
 
-u16 ping_port_rover;
+static u16 ping_port_rover;
 
 static inline int ping_hashfn(struct net *net, unsigned num, unsigned mask)
 {
@@ -150,8 +150,8 @@ static void ping_v4_unhash(struct sock *sk)
 	}
 }
 
-struct sock *ping_v4_lookup(struct net *net, u32 saddr, u32 daddr,
-	 u16 ident, int dif)
+static struct sock *ping_v4_lookup(struct net *net, u32 saddr, u32 daddr,
+				   u16 ident, int dif)
 {
 	struct hlist_nulls_head *hslot = ping_hashslot(&ping_table, net, ident);
 	struct sock *sk = NULL;


