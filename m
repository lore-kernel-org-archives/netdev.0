From: kaber@trash.net
Subject: [PATCH 27/72] netfilter: nf_nat: make find/put static
Date: Thu, 21 Oct 2010 17:19:14 +0200
Message-ID: <1287674399-31455-28-git-send-email-kaber@trash.net>
References: <1287674399-31455-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1287674399-31455-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@vyatta.com>

The functions nf_nat_proto_find_get and nf_nat_proto_put are
only used internally in nf_nat_core. This might break some out
of tree NAT module.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/net/netfilter/nf_nat_protocol.h |    3 ---
 net/ipv4/netfilter/nf_nat_core.c        |    6 ++----
 2 files changed, 2 insertions(+), 7 deletions(-)

diff --git a/include/net/netfilter/nf_nat_protocol.h b/include/net/netfilter/nf_nat_protocol.h
index df17bac..93cc90d 100644
--- a/include/net/netfilter/nf_nat_protocol.h
+++ b/include/net/netfilter/nf_nat_protocol.h
@@ -45,9 +45,6 @@ struct nf_nat_protocol {
 extern int nf_nat_protocol_register(const struct nf_nat_protocol *proto);
 extern void nf_nat_protocol_unregister(const struct nf_nat_protocol *proto);
 
-extern const struct nf_nat_protocol *nf_nat_proto_find_get(u_int8_t protocol);
-extern void nf_nat_proto_put(const struct nf_nat_protocol *proto);
-
 /* Built-in protocols. */
 extern const struct nf_nat_protocol nf_nat_protocol_tcp;
 extern const struct nf_nat_protocol nf_nat_protocol_udp;
diff --git a/net/ipv4/netfilter/nf_nat_core.c b/net/ipv4/netfilter/nf_nat_core.c
index 2c084b3..e2e00c4 100644
--- a/net/ipv4/netfilter/nf_nat_core.c
+++ b/net/ipv4/netfilter/nf_nat_core.c
@@ -47,7 +47,7 @@ __nf_nat_proto_find(u_int8_t protonum)
 	return rcu_dereference(nf_nat_protos[protonum]);
 }
 
-const struct nf_nat_protocol *
+static const struct nf_nat_protocol *
 nf_nat_proto_find_get(u_int8_t protonum)
 {
 	const struct nf_nat_protocol *p;
@@ -60,14 +60,12 @@ nf_nat_proto_find_get(u_int8_t protonum)
 
 	return p;
 }
-EXPORT_SYMBOL_GPL(nf_nat_proto_find_get);
 
-void
+static void
 nf_nat_proto_put(const struct nf_nat_protocol *p)
 {
 	module_put(p->me);
 }
-EXPORT_SYMBOL_GPL(nf_nat_proto_put);
 
 /* We keep an extra hash for each conntrack, for fast searching. */
 static inline unsigned int
-- 
1.7.1

