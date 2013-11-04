From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 14/20] netfilter:ipset: Fix memory allocation for bitmap:port
Date: Mon,  4 Nov 2013 22:50:36 +0100
Message-ID: <1383601842-4570-15-git-send-email-pablo@netfilter.org>
References: <1383601842-4570-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1383601842-4570-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

At the restructuring of the bitmap types creation in ipset, for the
bitmap:port type wrong (too large) memory allocation was copied
(netfilter bugzilla id #859).

Reported-by: Quentin Armitage <quentin@armitage.org.uk>
Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
---
 net/netfilter/ipset/ip_set_bitmap_port.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/netfilter/ipset/ip_set_bitmap_port.c b/net/netfilter/ipset/ip_set_bitmap_port.c
index e7603c5..cf99676 100644
--- a/net/netfilter/ipset/ip_set_bitmap_port.c
+++ b/net/netfilter/ipset/ip_set_bitmap_port.c
@@ -254,7 +254,7 @@ bitmap_port_create(struct net *net, struct ip_set *set, struct nlattr *tb[],
 		return -ENOMEM;
 
 	map->elements = last_port - first_port + 1;
-	map->memsize = map->elements * sizeof(unsigned long);
+	map->memsize = bitmap_bytes(0, map->elements);
 	set->variant = &bitmap_port;
 	set->dsize = ip_set_elem_len(set, tb, 0);
 	if (!init_map_port(set, map, first_port, last_port)) {
-- 
1.7.10.4

