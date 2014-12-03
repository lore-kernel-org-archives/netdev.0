From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 12/12] netfilter: ipset: Explicitly add padding elements to hash:net, net and hash:net, port, net
Date: Wed,  3 Dec 2014 13:55:42 +0100
Message-ID: <1417611342-25257-13-git-send-email-pablo@netfilter.org>
References: <1417611342-25257-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1417611342-25257-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>

The elements must be u32 sized for the used hash function.

Signed-off-by: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/ipset/ip_set_hash_netnet.c     |    2 ++
 net/netfilter/ipset/ip_set_hash_netportnet.c |    2 ++
 2 files changed, 4 insertions(+)

diff --git a/net/netfilter/ipset/ip_set_hash_netnet.c b/net/netfilter/ipset/ip_set_hash_netnet.c
index da00284..ea8772a 100644
--- a/net/netfilter/ipset/ip_set_hash_netnet.c
+++ b/net/netfilter/ipset/ip_set_hash_netnet.c
@@ -46,6 +46,7 @@ struct hash_netnet4_elem {
 		__be64 ipcmp;
 	};
 	u8 nomatch;
+	u8 padding;
 	union {
 		u8 cidr[2];
 		u16 ccmp;
@@ -271,6 +272,7 @@ hash_netnet4_uadt(struct ip_set *set, struct nlattr *tb[],
 struct hash_netnet6_elem {
 	union nf_inet_addr ip[2];
 	u8 nomatch;
+	u8 padding;
 	union {
 		u8 cidr[2];
 		u16 ccmp;
diff --git a/net/netfilter/ipset/ip_set_hash_netportnet.c b/net/netfilter/ipset/ip_set_hash_netportnet.c
index b8053d6..bfaa94c 100644
--- a/net/netfilter/ipset/ip_set_hash_netportnet.c
+++ b/net/netfilter/ipset/ip_set_hash_netportnet.c
@@ -53,6 +53,7 @@ struct hash_netportnet4_elem {
 		u8 cidr[2];
 		u16 ccmp;
 	};
+	u16 padding;
 	u8 nomatch:1;
 	u8 proto;
 };
@@ -324,6 +325,7 @@ struct hash_netportnet6_elem {
 		u8 cidr[2];
 		u16 ccmp;
 	};
+	u16 padding;
 	u8 nomatch:1;
 	u8 proto;
 };
-- 
1.7.10.4

