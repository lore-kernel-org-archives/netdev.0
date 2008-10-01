From: KOVACS Krisztian <hidden@sch.bme.hu>
Subject: [net-next PATCH 09/16] Export UDP socket lookup function
Date: Wed, 01 Oct 2008 16:24:31 +0200
Message-ID: <20081001142431.4893.2247.stgit@este>
References: <20081001142431.4893.48078.stgit@este>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7BIT
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-reply-to: <20081001142431.4893.48078.stgit@este>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The iptables tproxy code has to be able to do UDP socket hash lookups,
so we have to provide an exported lookup function for this purpose.

Signed-off-by: KOVACS Krisztian <hidden@sch.bme.hu>
---

 include/net/udp.h |    4 ++++
 net/ipv4/udp.c    |    7 +++++++
 2 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/include/net/udp.h b/include/net/udp.h
index addcdc6..d38f6f2 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -148,6 +148,10 @@ extern int 	udp_lib_setsockopt(struct sock *sk, int level, int optname,
 				   char __user *optval, int optlen,
 				   int (*push_pending_frames)(struct sock *));
 
+extern struct sock *udp4_lib_lookup(struct net *net, __be32 saddr, __be16 sport,
+				    __be32 daddr, __be16 dport,
+				    int dif);
+
 DECLARE_SNMP_STAT(struct udp_mib, udp_stats_in6);
 
 /* UDP-Lite does not have a standardized MIB yet, so we inherit from UDP */
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 8e42fbb..28c3c31 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -302,6 +302,13 @@ static struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr,
 	return result;
 }
 
+struct sock *udp4_lib_lookup(struct net *net, __be32 saddr, __be16 sport,
+			     __be32 daddr, __be16 dport, int dif)
+{
+	return __udp4_lib_lookup(net, saddr, sport, daddr, dport, dif, udp_hash);
+}
+EXPORT_SYMBOL_GPL(udp4_lib_lookup);
+
 static inline struct sock *udp_v4_mcast_next(struct sock *sk,
 					     __be16 loc_port, __be32 loc_addr,
 					     __be16 rmt_port, __be32 rmt_addr,


