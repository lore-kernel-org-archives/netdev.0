From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next] nf_nat: make find/put static
Date: Sat, 2 Oct 2010 14:17:36 +0900
Message-ID: <20101002141736.0a31bcd7@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The functions nf_nat_proto_find_get and nf_nat_proto_put are
only used internally in nf_nat_core. This might break some out
of tree NAT module.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/include/net/netfilter/nf_nat_protocol.h	2010-10-02 09:01:09.153396885 +0900
+++ b/include/net/netfilter/nf_nat_protocol.h	2010-10-02 09:01:55.340910304 +0900
@@ -45,9 +45,6 @@ struct nf_nat_protocol {
 extern int nf_nat_protocol_register(const struct nf_nat_protocol *proto);
 extern void nf_nat_protocol_unregister(const struct nf_nat_protocol *proto);
 
-extern const struct nf_nat_protocol *nf_nat_proto_find_get(u_int8_t protocol);
-extern void nf_nat_proto_put(const struct nf_nat_protocol *proto);
-
 /* Built-in protocols. */
 extern const struct nf_nat_protocol nf_nat_protocol_tcp;
 extern const struct nf_nat_protocol nf_nat_protocol_udp;
--- a/net/ipv4/netfilter/nf_nat_core.c	2010-10-02 09:01:09.183396507 +0900
+++ b/net/ipv4/netfilter/nf_nat_core.c	2010-10-02 09:01:55.340910304 +0900
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

