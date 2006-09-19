From: Brian Haley <brian.haley@hp.com>
Subject: [PATCH] make some netfilter globals __read_mostly
Date: Tue, 19 Sep 2006 15:33:46 -0400
Message-ID: <4510461A.9060700@hp.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020004090200030303050003"
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel8.hp.com ([156.153.255.206]:26518 "EHLO atlrel8.hp.com")
	by vger.kernel.org with ESMTP id S1751059AbWISTdt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2006 15:33:49 -0400
To: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020004090200030303050003
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Make some netfilter globals __read_mostly at the request of Patrick McHardy.

Signed-off-by: Brian Haley <brian.haley@hp.com>

--------------020004090200030303050003
Content-Type: text/x-patch;
 name="nf.read_mostly.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="nf.read_mostly.patch"

diff --git a/net/ipv4/netfilter/ip_conntrack_core.c b/net/ipv4/netfilter/ip_conntrack_core.c
index aa45917..2370245 100644
--- a/net/ipv4/netfilter/ip_conntrack_core.c
+++ b/net/ipv4/netfilter/ip_conntrack_core.c
@@ -64,17 +64,17 @@ atomic_t ip_conntrack_count = ATOMIC_INI
 
 void (*ip_conntrack_destroyed)(struct ip_conntrack *conntrack) = NULL;
 LIST_HEAD(ip_conntrack_expect_list);
-struct ip_conntrack_protocol *ip_ct_protos[MAX_IP_CT_PROTO];
+struct ip_conntrack_protocol *ip_ct_protos[MAX_IP_CT_PROTO] __read_mostly;
 static LIST_HEAD(helpers);
 unsigned int ip_conntrack_htable_size = 0;
 int ip_conntrack_max;
-struct list_head *ip_conntrack_hash;
+struct list_head *ip_conntrack_hash __read_mostly;
 static kmem_cache_t *ip_conntrack_cachep __read_mostly;
 static kmem_cache_t *ip_conntrack_expect_cachep __read_mostly;
 struct ip_conntrack ip_conntrack_untracked;
 unsigned int ip_ct_log_invalid;
 static LIST_HEAD(unconfirmed);
-static int ip_conntrack_vmalloc;
+static int ip_conntrack_vmalloc __read_mostly;
 
 static unsigned int ip_conntrack_next_id;
 static unsigned int ip_conntrack_expect_next_id;
diff --git a/net/ipv4/netfilter/ip_queue.c b/net/ipv4/netfilter/ip_queue.c
index 276a964..de680e5 100644
--- a/net/ipv4/netfilter/ip_queue.c
+++ b/net/ipv4/netfilter/ip_queue.c
@@ -52,15 +52,15 @@ struct ipq_queue_entry {
 
 typedef int (*ipq_cmpfn)(struct ipq_queue_entry *, unsigned long);
 
-static unsigned char copy_mode = IPQ_COPY_NONE;
+static unsigned char copy_mode __read_mostly = IPQ_COPY_NONE;
 static unsigned int queue_maxlen = IPQ_QMAX_DEFAULT;
 static DEFINE_RWLOCK(queue_lock);
-static int peer_pid;
-static unsigned int copy_range;
+static int peer_pid __read_mostly;
+static unsigned int copy_range __read_mostly;
 static unsigned int queue_total;
 static unsigned int queue_dropped = 0;
 static unsigned int queue_user_dropped = 0;
-static struct sock *ipqnl;
+static struct sock *ipqnl __read_mostly;
 static LIST_HEAD(queue_list);
 static DEFINE_MUTEX(ipqnl_mutex);
 
diff --git a/net/ipv6/netfilter/ip6_queue.c b/net/ipv6/netfilter/ip6_queue.c
index c01c126..c74d1cc 100644
--- a/net/ipv6/netfilter/ip6_queue.c
+++ b/net/ipv6/netfilter/ip6_queue.c
@@ -56,15 +56,15 @@ struct ipq_queue_entry {
 
 typedef int (*ipq_cmpfn)(struct ipq_queue_entry *, unsigned long);
 
-static unsigned char copy_mode = IPQ_COPY_NONE;
+static unsigned char copy_mode __read_mostly = IPQ_COPY_NONE;
 static unsigned int queue_maxlen = IPQ_QMAX_DEFAULT;
 static DEFINE_RWLOCK(queue_lock);
-static int peer_pid;
-static unsigned int copy_range;
+static int peer_pid __read_mostly;
+static unsigned int copy_range __read_mostly;
 static unsigned int queue_total;
 static unsigned int queue_dropped = 0;
 static unsigned int queue_user_dropped = 0;
-static struct sock *ipqnl;
+static struct sock *ipqnl __read_mostly;
 static LIST_HEAD(queue_list);
 static DEFINE_MUTEX(ipqnl_mutex);
 
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 8f22619..d50c52d 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -74,17 +74,17 @@ atomic_t nf_conntrack_count = ATOMIC_INI
 
 void (*nf_conntrack_destroyed)(struct nf_conn *conntrack) = NULL;
 LIST_HEAD(nf_conntrack_expect_list);
-struct nf_conntrack_protocol **nf_ct_protos[PF_MAX];
-struct nf_conntrack_l3proto *nf_ct_l3protos[PF_MAX];
+struct nf_conntrack_protocol **nf_ct_protos[PF_MAX] __read_mostly;
+struct nf_conntrack_l3proto *nf_ct_l3protos[PF_MAX] __read_mostly;
 static LIST_HEAD(helpers);
 unsigned int nf_conntrack_htable_size = 0;
 int nf_conntrack_max;
-struct list_head *nf_conntrack_hash;
-static kmem_cache_t *nf_conntrack_expect_cachep;
+struct list_head *nf_conntrack_hash __read_mostly;
+static kmem_cache_t *nf_conntrack_expect_cachep __read_mostly;
 struct nf_conn nf_conntrack_untracked;
 unsigned int nf_ct_log_invalid;
 static LIST_HEAD(unconfirmed);
-static int nf_conntrack_vmalloc;
+static int nf_conntrack_vmalloc __read_mostly;
 
 static unsigned int nf_conntrack_next_id;
 static unsigned int nf_conntrack_expect_next_id;

--------------020004090200030303050003--
