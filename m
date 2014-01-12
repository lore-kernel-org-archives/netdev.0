From: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Subject: [PATCH net-next] ipv4: remove the  useless argument from ip_tunnel_hash()
Date: Sun, 12 Jan 2014 18:04:10 +0800
Message-ID: <52D2689A.4040800@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:32579 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751114AbaALKEk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Jan 2014 05:04:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Since commit c544193214 introduced function ip_tunnel_hash(), the argument
itn is no longer in use, so remove it.

Signed-off-by: Duan Jiong <duanj.fnst@cn.fujitsu.com>
---
 net/ipv4/ip_tunnel.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index d3929a6..6f5a347 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -61,8 +61,7 @@
 #include <net/ip6_route.h>
 #endif
 
-static unsigned int ip_tunnel_hash(struct ip_tunnel_net *itn,
-				   __be32 key, __be32 remote)
+static unsigned int ip_tunnel_hash(__be32 key, __be32 remote)
 {
 	return hash_32((__force u32)key ^ (__force u32)remote,
 			 IP_TNL_HASH_BITS);
@@ -204,7 +203,7 @@ struct ip_tunnel *ip_tunnel_lookup(struct ip_tunnel_net *itn,
 	struct ip_tunnel *t, *cand = NULL;
 	struct hlist_head *head;
 
-	hash = ip_tunnel_hash(itn, key, remote);
+	hash = ip_tunnel_hash(key, remote);
 	head = &itn->tunnels[hash];
 
 	hlist_for_each_entry_rcu(t, head, hash_node) {
@@ -236,7 +235,7 @@ struct ip_tunnel *ip_tunnel_lookup(struct ip_tunnel_net *itn,
 			cand = t;
 	}
 
-	hash = ip_tunnel_hash(itn, key, 0);
+	hash = ip_tunnel_hash(key, 0);
 	head = &itn->tunnels[hash];
 
 	hlist_for_each_entry_rcu(t, head, hash_node) {
@@ -292,7 +291,7 @@ static struct hlist_head *ip_bucket(struct ip_tunnel_net *itn,
 	else
 		remote = 0;
 
-	h = ip_tunnel_hash(itn, parms->i_key, remote);
+	h = ip_tunnel_hash(parms->i_key, remote);
 	return &itn->tunnels[h];
 }
 
-- 
1.8.3.1
