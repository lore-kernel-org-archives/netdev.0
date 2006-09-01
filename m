From: Brian Haley <brian.haley@hp.com>
Subject: [PATCH] change netfilter tunables to __read_mostly
Date: Fri, 01 Sep 2006 11:32:06 -0400
Message-ID: <44F85276.1020804@hp.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000603060708080102070801"
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:42176 "EHLO atlrel6.hp.com")
	by vger.kernel.org with ESMTP id S1751562AbWIAPcK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2006 11:32:10 -0400
To: David Miller <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------000603060708080102070801
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Change some netfilter tunables to __read_mostly.  Also fixed some 
incorrect file reference comments while I was in there.

(this will be my last __read_mostly patch unless someone points out 
something else that needs it)

Signed-off-by: Brian Haley <brian.haley@hp.com>

--------------000603060708080102070801
Content-Type: text/x-patch;
 name="netfilter.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="netfilter.patch"

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 8f22619..3b64dbe 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -77,12 +77,12 @@ LIST_HEAD(nf_conntrack_expect_list);
 struct nf_conntrack_protocol **nf_ct_protos[PF_MAX];
 struct nf_conntrack_l3proto *nf_ct_l3protos[PF_MAX];
 static LIST_HEAD(helpers);
-unsigned int nf_conntrack_htable_size = 0;
-int nf_conntrack_max;
+unsigned int nf_conntrack_htable_size __read_mostly = 0;
+int nf_conntrack_max __read_mostly;
 struct list_head *nf_conntrack_hash;
 static kmem_cache_t *nf_conntrack_expect_cachep;
 struct nf_conn nf_conntrack_untracked;
-unsigned int nf_ct_log_invalid;
+unsigned int nf_ct_log_invalid __read_mostly;
 static LIST_HEAD(unconfirmed);
 static int nf_conntrack_vmalloc;
 
diff --git a/net/netfilter/nf_conntrack_proto_generic.c b/net/netfilter/nf_conntrack_proto_generic.c
index 46bc27e..26408bb 100644
--- a/net/netfilter/nf_conntrack_proto_generic.c
+++ b/net/netfilter/nf_conntrack_proto_generic.c
@@ -17,7 +17,7 @@
 #include <linux/netfilter.h>
 #include <net/netfilter/nf_conntrack_protocol.h>
 
-unsigned int nf_ct_generic_timeout = 600*HZ;
+unsigned int nf_ct_generic_timeout __read_mostly = 600*HZ;
 
 static int generic_pkt_to_tuple(const struct sk_buff *skb,
 				unsigned int dataoff,
diff --git a/net/netfilter/nf_conntrack_proto_sctp.c b/net/netfilter/nf_conntrack_proto_sctp.c
index 9bd8a78..af56877 100644
--- a/net/netfilter/nf_conntrack_proto_sctp.c
+++ b/net/netfilter/nf_conntrack_proto_sctp.c
@@ -64,13 +64,13 @@ static const char *sctp_conntrack_names[
 #define HOURS * 60 MINS
 #define DAYS  * 24 HOURS
 
-static unsigned int nf_ct_sctp_timeout_closed            =  10 SECS;
-static unsigned int nf_ct_sctp_timeout_cookie_wait       =   3 SECS;
-static unsigned int nf_ct_sctp_timeout_cookie_echoed     =   3 SECS;
-static unsigned int nf_ct_sctp_timeout_established       =   5 DAYS;
-static unsigned int nf_ct_sctp_timeout_shutdown_sent     = 300 SECS / 1000;
-static unsigned int nf_ct_sctp_timeout_shutdown_recd     = 300 SECS / 1000;
-static unsigned int nf_ct_sctp_timeout_shutdown_ack_sent =   3 SECS;
+static unsigned int nf_ct_sctp_timeout_closed __read_mostly          =  10 SECS;
+static unsigned int nf_ct_sctp_timeout_cookie_wait __read_mostly     =   3 SECS;
+static unsigned int nf_ct_sctp_timeout_cookie_echoed __read_mostly   =   3 SECS;
+static unsigned int nf_ct_sctp_timeout_established __read_mostly     =   5 DAYS;
+static unsigned int nf_ct_sctp_timeout_shutdown_sent __read_mostly   = 300 SECS / 1000;
+static unsigned int nf_ct_sctp_timeout_shutdown_recd __read_mostly   = 300 SECS / 1000;
+static unsigned int nf_ct_sctp_timeout_shutdown_ack_sent __read_mostly = 3 SECS;
 
 static unsigned int * sctp_timeouts[]
 = { NULL,                                  /* SCTP_CONNTRACK_NONE  */
diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
index 308d2ab..9fc0ee6 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -57,19 +57,19 @@ static DEFINE_RWLOCK(tcp_lock);
 /* "Be conservative in what you do, 
     be liberal in what you accept from others." 
     If it's non-zero, we mark only out of window RST segments as INVALID. */
-int nf_ct_tcp_be_liberal = 0;
+int nf_ct_tcp_be_liberal __read_mostly = 0;
 
 /* When connection is picked up from the middle, how many packets are required
    to pass in each direction when we assume we are in sync - if any side uses
    window scaling, we lost the game. 
    If it is set to zero, we disable picking up already established 
    connections. */
-int nf_ct_tcp_loose = 3;
+int nf_ct_tcp_loose __read_mostly = 3;
 
 /* Max number of the retransmitted packets without receiving an (acceptable) 
    ACK from the destination. If this number is reached, a shorter timer 
    will be started. */
-int nf_ct_tcp_max_retrans = 3;
+int nf_ct_tcp_max_retrans __read_mostly = 3;
 
   /* FIXME: Examine ipfilter's timeouts and conntrack transitions more
      closely.  They're more complex. --RR */
@@ -92,19 +92,19 @@ static const char *tcp_conntrack_names[]
 #define HOURS * 60 MINS
 #define DAYS * 24 HOURS
 
-unsigned int nf_ct_tcp_timeout_syn_sent =      2 MINS;
-unsigned int nf_ct_tcp_timeout_syn_recv =     60 SECS;
-unsigned int nf_ct_tcp_timeout_established =   5 DAYS;
-unsigned int nf_ct_tcp_timeout_fin_wait =      2 MINS;
-unsigned int nf_ct_tcp_timeout_close_wait =   60 SECS;
-unsigned int nf_ct_tcp_timeout_last_ack =     30 SECS;
-unsigned int nf_ct_tcp_timeout_time_wait =     2 MINS;
-unsigned int nf_ct_tcp_timeout_close =        10 SECS;
+unsigned int nf_ct_tcp_timeout_syn_sent __read_mostly =      2 MINS;
+unsigned int nf_ct_tcp_timeout_syn_recv __read_mostly =     60 SECS;
+unsigned int nf_ct_tcp_timeout_established __read_mostly =   5 DAYS;
+unsigned int nf_ct_tcp_timeout_fin_wait __read_mostly =      2 MINS;
+unsigned int nf_ct_tcp_timeout_close_wait __read_mostly =   60 SECS;
+unsigned int nf_ct_tcp_timeout_last_ack __read_mostly =     30 SECS;
+unsigned int nf_ct_tcp_timeout_time_wait __read_mostly =     2 MINS;
+unsigned int nf_ct_tcp_timeout_close __read_mostly =        10 SECS;
 
 /* RFC1122 says the R2 limit should be at least 100 seconds.
    Linux uses 15 packets as limit, which corresponds 
    to ~13-30min depending on RTO. */
-unsigned int nf_ct_tcp_timeout_max_retrans =     5 MINS;
+unsigned int nf_ct_tcp_timeout_max_retrans __read_mostly =   5 MINS;
  
 static unsigned int * tcp_timeouts[]
 = { NULL,                              /* TCP_CONNTRACK_NONE */
diff --git a/net/netfilter/nf_conntrack_proto_udp.c b/net/netfilter/nf_conntrack_proto_udp.c
index d36e031..d28981c 100644
--- a/net/netfilter/nf_conntrack_proto_udp.c
+++ b/net/netfilter/nf_conntrack_proto_udp.c
@@ -27,8 +27,8 @@
 #include <linux/netfilter_ipv6.h>
 #include <net/netfilter/nf_conntrack_protocol.h>
 
-unsigned int nf_ct_udp_timeout = 30*HZ;
-unsigned int nf_ct_udp_timeout_stream = 180*HZ;
+unsigned int nf_ct_udp_timeout __read_mostly = 30*HZ;
+unsigned int nf_ct_udp_timeout_stream __read_mostly = 180*HZ;
 
 static int udp_pkt_to_tuple(const struct sk_buff *skb,
 			     unsigned int dataoff,
diff --git a/net/netfilter/nf_conntrack_standalone.c b/net/netfilter/nf_conntrack_standalone.c
index 4ef8366..9a1de0c 100644
--- a/net/netfilter/nf_conntrack_standalone.c
+++ b/net/netfilter/nf_conntrack_standalone.c
@@ -428,7 +428,7 @@ static struct file_operations ct_cpu_seq
 
 /* Sysctl support */
 
-int nf_conntrack_checksum = 1;
+int nf_conntrack_checksum __read_mostly = 1;
 
 #ifdef CONFIG_SYSCTL
 
diff --git a/net/ipv4/netfilter/ip_conntrack_core.c b/net/ipv4/netfilter/ip_conntrack_core.c
index aa45917..5da25ad 100644
--- a/net/ipv4/netfilter/ip_conntrack_core.c
+++ b/net/ipv4/netfilter/ip_conntrack_core.c
@@ -66,13 +66,13 @@ void (*ip_conntrack_destroyed)(struct ip
 LIST_HEAD(ip_conntrack_expect_list);
 struct ip_conntrack_protocol *ip_ct_protos[MAX_IP_CT_PROTO];
 static LIST_HEAD(helpers);
-unsigned int ip_conntrack_htable_size = 0;
-int ip_conntrack_max;
+unsigned int ip_conntrack_htable_size __read_mostly = 0;
+int ip_conntrack_max __read_mostly;
 struct list_head *ip_conntrack_hash;
 static kmem_cache_t *ip_conntrack_cachep __read_mostly;
 static kmem_cache_t *ip_conntrack_expect_cachep __read_mostly;
 struct ip_conntrack ip_conntrack_untracked;
-unsigned int ip_ct_log_invalid;
+unsigned int ip_ct_log_invalid __read_mostly;
 static LIST_HEAD(unconfirmed);
 static int ip_conntrack_vmalloc;
 
diff --git a/net/ipv4/netfilter/ip_conntrack_proto_generic.c b/net/ipv4/netfilter/ip_conntrack_proto_generic.c
index f891308..36f2b5e 100644
--- a/net/ipv4/netfilter/ip_conntrack_proto_generic.c
+++ b/net/ipv4/netfilter/ip_conntrack_proto_generic.c
@@ -12,7 +12,7 @@
 #include <linux/netfilter.h>
 #include <linux/netfilter_ipv4/ip_conntrack_protocol.h>
 
-unsigned int ip_ct_generic_timeout = 600*HZ;
+unsigned int ip_ct_generic_timeout __read_mostly = 600*HZ;
 
 static int generic_pkt_to_tuple(const struct sk_buff *skb,
 				unsigned int dataoff,
diff --git a/net/ipv4/netfilter/ip_conntrack_proto_icmp.c b/net/ipv4/netfilter/ip_conntrack_proto_icmp.c
index 23f1c50..09c40eb 100644
--- a/net/ipv4/netfilter/ip_conntrack_proto_icmp.c
+++ b/net/ipv4/netfilter/ip_conntrack_proto_icmp.c
@@ -21,7 +21,7 @@
 #include <linux/netfilter_ipv4/ip_conntrack_core.h>
 #include <linux/netfilter_ipv4/ip_conntrack_protocol.h>
 
-unsigned int ip_ct_icmp_timeout = 30*HZ;
+unsigned int ip_ct_icmp_timeout __read_mostly = 30*HZ;
 
 #if 0
 #define DEBUGP printk
diff --git a/net/ipv4/netfilter/ip_conntrack_proto_sctp.c b/net/ipv4/netfilter/ip_conntrack_proto_sctp.c
index 2d3612c..b908a48 100644
--- a/net/ipv4/netfilter/ip_conntrack_proto_sctp.c
+++ b/net/ipv4/netfilter/ip_conntrack_proto_sctp.c
@@ -58,13 +58,13 @@ static const char *sctp_conntrack_names[
 #define HOURS * 60 MINS
 #define DAYS  * 24 HOURS
 
-static unsigned int ip_ct_sctp_timeout_closed            =  10 SECS;
-static unsigned int ip_ct_sctp_timeout_cookie_wait       =   3 SECS;
-static unsigned int ip_ct_sctp_timeout_cookie_echoed     =   3 SECS;
-static unsigned int ip_ct_sctp_timeout_established       =   5 DAYS;
-static unsigned int ip_ct_sctp_timeout_shutdown_sent     = 300 SECS / 1000;
-static unsigned int ip_ct_sctp_timeout_shutdown_recd     = 300 SECS / 1000;
-static unsigned int ip_ct_sctp_timeout_shutdown_ack_sent =   3 SECS;
+static unsigned int ip_ct_sctp_timeout_closed __read_mostly           = 10 SECS;
+static unsigned int ip_ct_sctp_timeout_cookie_wait __read_mostly      =  3 SECS;
+static unsigned int ip_ct_sctp_timeout_cookie_echoed __read_mostly    =  3 SECS;
+static unsigned int ip_ct_sctp_timeout_established __read_mostly      =  5 DAYS;
+static unsigned int ip_ct_sctp_timeout_shutdown_sent __read_mostly    = 300 SECS / 1000;
+static unsigned int ip_ct_sctp_timeout_shutdown_recd __read_mostly    = 300 SECS / 1000;
+static unsigned int ip_ct_sctp_timeout_shutdown_ack_sent __read_mostly = 3 SECS;
 
 static const unsigned int * sctp_timeouts[]
 = { NULL,                                  /* SCTP_CONNTRACK_NONE  */
diff --git a/net/ipv4/netfilter/ip_conntrack_proto_tcp.c b/net/ipv4/netfilter/ip_conntrack_proto_tcp.c
index 9de81ff..75a7237 100644
--- a/net/ipv4/netfilter/ip_conntrack_proto_tcp.c
+++ b/net/ipv4/netfilter/ip_conntrack_proto_tcp.c
@@ -48,19 +48,19 @@ static DEFINE_RWLOCK(tcp_lock);
 /* "Be conservative in what you do, 
     be liberal in what you accept from others." 
     If it's non-zero, we mark only out of window RST segments as INVALID. */
-int ip_ct_tcp_be_liberal = 0;
+int ip_ct_tcp_be_liberal __read_mostly = 0;
 
 /* When connection is picked up from the middle, how many packets are required
    to pass in each direction when we assume we are in sync - if any side uses
    window scaling, we lost the game. 
    If it is set to zero, we disable picking up already established 
    connections. */
-int ip_ct_tcp_loose = 3;
+int ip_ct_tcp_loose __read_mostly = 3;
 
 /* Max number of the retransmitted packets without receiving an (acceptable) 
    ACK from the destination. If this number is reached, a shorter timer 
    will be started. */
-int ip_ct_tcp_max_retrans = 3;
+int ip_ct_tcp_max_retrans __read_mostly = 3;
 
   /* FIXME: Examine ipfilter's timeouts and conntrack transitions more
      closely.  They're more complex. --RR */
@@ -83,19 +83,19 @@ static const char *tcp_conntrack_names[]
 #define HOURS * 60 MINS
 #define DAYS * 24 HOURS
 
-unsigned int ip_ct_tcp_timeout_syn_sent =      2 MINS;
-unsigned int ip_ct_tcp_timeout_syn_recv =     60 SECS;
-unsigned int ip_ct_tcp_timeout_established =   5 DAYS;
-unsigned int ip_ct_tcp_timeout_fin_wait =      2 MINS;
-unsigned int ip_ct_tcp_timeout_close_wait =   60 SECS;
-unsigned int ip_ct_tcp_timeout_last_ack =     30 SECS;
-unsigned int ip_ct_tcp_timeout_time_wait =     2 MINS;
-unsigned int ip_ct_tcp_timeout_close =        10 SECS;
+unsigned int ip_ct_tcp_timeout_syn_sent __read_mostly =      2 MINS;
+unsigned int ip_ct_tcp_timeout_syn_recv __read_mostly =     60 SECS;
+unsigned int ip_ct_tcp_timeout_established __read_mostly =   5 DAYS;
+unsigned int ip_ct_tcp_timeout_fin_wait __read_mostly =      2 MINS;
+unsigned int ip_ct_tcp_timeout_close_wait __read_mostly =   60 SECS;
+unsigned int ip_ct_tcp_timeout_last_ack __read_mostly =     30 SECS;
+unsigned int ip_ct_tcp_timeout_time_wait __read_mostly =     2 MINS;
+unsigned int ip_ct_tcp_timeout_close __read_mostly =        10 SECS;
 
 /* RFC1122 says the R2 limit should be at least 100 seconds.
    Linux uses 15 packets as limit, which corresponds 
    to ~13-30min depending on RTO. */
-unsigned int ip_ct_tcp_timeout_max_retrans =     5 MINS;
+unsigned int ip_ct_tcp_timeout_max_retrans __read_mostly =   5 MINS;
  
 static const unsigned int * tcp_timeouts[]
 = { NULL,                              /*      TCP_CONNTRACK_NONE */
diff --git a/net/ipv4/netfilter/ip_conntrack_proto_udp.c b/net/ipv4/netfilter/ip_conntrack_proto_udp.c
index e58e52f..d0e8a16 100644
--- a/net/ipv4/netfilter/ip_conntrack_proto_udp.c
+++ b/net/ipv4/netfilter/ip_conntrack_proto_udp.c
@@ -18,8 +18,8 @@
 #include <linux/netfilter_ipv4.h>
 #include <linux/netfilter_ipv4/ip_conntrack_protocol.h>
 
-unsigned int ip_ct_udp_timeout = 30*HZ;
-unsigned int ip_ct_udp_timeout_stream = 180*HZ;
+unsigned int ip_ct_udp_timeout __read_mostly = 30*HZ;
+unsigned int ip_ct_udp_timeout_stream __read_mostly = 180*HZ;
 
 static int udp_pkt_to_tuple(const struct sk_buff *skb,
 			     unsigned int dataoff,
diff --git a/net/ipv4/netfilter/ip_conntrack_standalone.c b/net/ipv4/netfilter/ip_conntrack_standalone.c
index 7a9fa04..3f5d495 100644
--- a/net/ipv4/netfilter/ip_conntrack_standalone.c
+++ b/net/ipv4/netfilter/ip_conntrack_standalone.c
@@ -534,7 +534,7 @@ static struct nf_hook_ops ip_conntrack_o
 
 /* Sysctl support */
 
-int ip_conntrack_checksum = 1;
+int ip_conntrack_checksum __read_mostly = 1;
 
 #ifdef CONFIG_SYSCTL
 
@@ -563,7 +563,7 @@ extern unsigned int ip_ct_udp_timeout_st
 /* From ip_conntrack_proto_icmp.c */
 extern unsigned int ip_ct_icmp_timeout;
 
-/* From ip_conntrack_proto_icmp.c */
+/* From ip_conntrack_proto_generic.c */
 extern unsigned int ip_ct_generic_timeout;
 
 /* Log invalid packets of a given protocol */
diff --git a/net/ipv4/netfilter/ip_queue.c b/net/ipv4/netfilter/ip_queue.c
index 276a964..80060cb 100644
--- a/net/ipv4/netfilter/ip_queue.c
+++ b/net/ipv4/netfilter/ip_queue.c
@@ -53,7 +53,7 @@ struct ipq_queue_entry {
 typedef int (*ipq_cmpfn)(struct ipq_queue_entry *, unsigned long);
 
 static unsigned char copy_mode = IPQ_COPY_NONE;
-static unsigned int queue_maxlen = IPQ_QMAX_DEFAULT;
+static unsigned int queue_maxlen __read_mostly = IPQ_QMAX_DEFAULT;
 static DEFINE_RWLOCK(queue_lock);
 static int peer_pid;
 static unsigned int copy_range;
diff --git a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
index 663a73e..790f00d 100644
--- a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
+++ b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
@@ -25,7 +25,7 @@
 #include <net/netfilter/nf_conntrack_protocol.h>
 #include <net/netfilter/nf_conntrack_core.h>
 
-unsigned long nf_ct_icmp_timeout = 30*HZ;
+unsigned long nf_ct_icmp_timeout __read_mostly = 30*HZ;
 
 #if 0
 #define DEBUGP printk
diff --git a/net/ipv6/netfilter/ip6_queue.c b/net/ipv6/netfilter/ip6_queue.c
index c01c126..d322e83 100644
--- a/net/ipv6/netfilter/ip6_queue.c
+++ b/net/ipv6/netfilter/ip6_queue.c
@@ -57,7 +57,7 @@ struct ipq_queue_entry {
 typedef int (*ipq_cmpfn)(struct ipq_queue_entry *, unsigned long);
 
 static unsigned char copy_mode = IPQ_COPY_NONE;
-static unsigned int queue_maxlen = IPQ_QMAX_DEFAULT;
+static unsigned int queue_maxlen __read_mostly = IPQ_QMAX_DEFAULT;
 static DEFINE_RWLOCK(queue_lock);
 static int peer_pid;
 static unsigned int copy_range;
diff --git a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
index c2ab38f..e5e53ff 100644
--- a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
@@ -335,7 +335,7 @@ static struct nf_hook_ops ipv6_conntrack
 /* From nf_conntrack_proto_icmpv6.c */
 extern unsigned int nf_ct_icmpv6_timeout;
 
-/* From nf_conntrack_frag6.c */
+/* From nf_conntrack_reasm.c */
 extern unsigned int nf_ct_frag6_timeout;
 extern unsigned int nf_ct_frag6_low_thresh;
 extern unsigned int nf_ct_frag6_high_thresh;
diff --git a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
index ef18a7b..34d4472 100644
--- a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
@@ -33,7 +33,7 @@
 #include <net/netfilter/nf_conntrack_core.h>
 #include <net/netfilter/ipv6/nf_conntrack_icmpv6.h>
 
-unsigned long nf_ct_icmpv6_timeout = 30*HZ;
+unsigned long nf_ct_icmpv6_timeout __read_mostly = 30*HZ;
 
 #if 0
 #define DEBUGP printk
diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilter/nf_conntrack_reasm.c
index 7a4e4c2..bf93c1e 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -54,9 +54,9 @@
 #define NF_CT_FRAG6_LOW_THRESH 196608  /* == 192*1024 */
 #define NF_CT_FRAG6_TIMEOUT IPV6_FRAG_TIMEOUT
 
-unsigned int nf_ct_frag6_high_thresh = 256*1024;
-unsigned int nf_ct_frag6_low_thresh = 192*1024;
-unsigned long nf_ct_frag6_timeout = IPV6_FRAG_TIMEOUT;
+unsigned int nf_ct_frag6_high_thresh __read_mostly = 256*1024;
+unsigned int nf_ct_frag6_low_thresh __read_mostly = 192*1024;
+unsigned long nf_ct_frag6_timeout __read_mostly = IPV6_FRAG_TIMEOUT;
 
 struct nf_ct_frag6_skb_cb
 {

--------------000603060708080102070801--
