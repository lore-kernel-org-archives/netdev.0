From: KOVACS Krisztian <hidden@balabit.hu>
Subject: [PATCH/RFC 07/10] Export UDP socket lookup function
Date: Wed, 03 Jan 2007 17:37:28 +0100
Message-ID: <20070103163728.14635.58566.stgit@nienna.balabit>
References: <20070103163357.14635.37754.stgit@nienna.balabit>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: netfilter-devel@lists.netfilter.org, netdev@vger.kernel.org
In-Reply-To: <20070103163357.14635.37754.stgit@nienna.balabit>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

The iptables tproxy code has to be able to do UDP socket hash lookups,
so we have to provide an exported lookup function for this purpose.

Signed-off-by: KOVACS Krisztian <hidden@balabit.hu>

---

 include/net/udp.h |    4 ++++
 net/ipv4/udp.c    |    8 ++++++++
 2 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/include/net/udp.h b/include/net/udp.h
index 1b921fa..ea5aa31 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -141,6 +141,10 @@ extern int 	udp_lib_setsockopt(struct so
 				   char __user *optval, int optlen,
 				   int (*push_pending_frames)(struct sock *));
 
+extern struct sock *udp4_lib_lookup(__be32 saddr, __be16 sport,
+				    __be32 daddr, __be16 dport,
+				    int dif);
+
 DECLARE_SNMP_STAT(struct udp_mib, udp_statistics);
 /*
  * 	SNMP statistics for UDP and UDP-Lite
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 1b348f5..a44d3d3 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -284,6 +284,14 @@ static struct sock *__udp4_lib_lookup(__
 	return result;
 }
 
+struct sock *udp4_lib_lookup(__be32 saddr, __be16 sport,
+			     __be32 daddr, __be16 dport,
+			     int dif)
+{
+	return __udp4_lib_lookup(saddr, sport, daddr, dport, dif, udp_hash);
+}
+EXPORT_SYMBOL_GPL(udp4_lib_lookup);
+
 static inline struct sock *udp_v4_mcast_next(struct sock *sk,
 					     __be16 loc_port, __be32 loc_addr,
 					     __be16 rmt_port, __be32 rmt_addr,
