From: Brian Haley <brian.haley@hp.com>
Subject: [PATCH] Change some sysctl variables to __read_mostly
Date: Wed, 09 Aug 2006 11:09:02 -0400
Message-ID: <44D9FA8E.2030602@hp.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080505010705000901040706"
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel8.hp.com ([156.153.255.206]:47788 "EHLO atlrel8.hp.com")
	by vger.kernel.org with ESMTP id S1750937AbWHIPJG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2006 11:09:06 -0400
To: David Miller <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080505010705000901040706
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Change net/core, ipv4 and ipv6 sysctl variables to __read_mostly.

Couldn't actually measure any performance increase while testing (.3% I 
consider noise), but seems like the right thing to do.

Signed-off-by: Brian Haley <brian.haley@hp.com>

--------------080505010705000901040706
Content-Type: text/x-patch;
 name="net.sysctl.read_mostly.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="net.sysctl.read_mostly.patch"

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index d273cad..e3d8d9b 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -2449,7 +2449,7 @@ static struct neigh_sysctl_table {
 	ctl_table		neigh_neigh_dir[2];
 	ctl_table		neigh_proto_dir[2];
 	ctl_table		neigh_root_dir[2];
-} neigh_sysctl_template = {
+} neigh_sysctl_template __read_mostly = {
 	.neigh_vars = {
 		{
 			.ctl_name	= NET_NEIGH_MCAST_SOLICIT,
diff --git a/net/core/sock.c b/net/core/sock.c
index b67d868..cfaf090 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -187,13 +187,13 @@ static struct lock_class_key af_callback
 #define SK_RMEM_MAX		(_SK_MEM_OVERHEAD * _SK_MEM_PACKETS)
 
 /* Run time adjustable parameters. */
-__u32 sysctl_wmem_max = SK_WMEM_MAX;
-__u32 sysctl_rmem_max = SK_RMEM_MAX;
-__u32 sysctl_wmem_default = SK_WMEM_MAX;
-__u32 sysctl_rmem_default = SK_RMEM_MAX;
+__u32 sysctl_wmem_max __read_mostly = SK_WMEM_MAX;
+__u32 sysctl_rmem_max __read_mostly = SK_RMEM_MAX;
+__u32 sysctl_wmem_default __read_mostly = SK_WMEM_MAX;
+__u32 sysctl_rmem_default __read_mostly = SK_RMEM_MAX;
 
 /* Maximal space eaten by iovec or ancilliary data plus some space */
-int sysctl_optmem_max = sizeof(unsigned long)*(2*UIO_MAXIOV + 512);
+int sysctl_optmem_max __read_mostly = sizeof(unsigned long)*(2*UIO_MAXIOV+512);
 
 static int sock_set_timeout(long *timeo_p, char __user *optval, int optlen)
 {
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index fc40da3..701960e 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -392,7 +392,7 @@ int inet_release(struct socket *sock)
 }
 
 /* It is off by default, see below. */
-int sysctl_ip_nonlocal_bind;
+int sysctl_ip_nonlocal_bind __read_mostly;
 
 int inet_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 {
@@ -988,7 +988,7 @@ void inet_unregister_protosw(struct inet
  *      Shall we try to damage output packets if routing dev changes?
  */
 
-int sysctl_ip_dynaddr;
+int sysctl_ip_dynaddr __read_mostly;
 
 static int inet_sk_reselect_saddr(struct sock *sk)
 {
diff --git a/net/ipv4/icmp.c b/net/ipv4/icmp.c
index 6d223e5..c2ad07e 100644
--- a/net/ipv4/icmp.c
+++ b/net/ipv4/icmp.c
@@ -187,11 +187,11 @@ struct icmp_err icmp_err_convert[] = {
 };
 
 /* Control parameters for ECHO replies. */
-int sysctl_icmp_echo_ignore_all;
-int sysctl_icmp_echo_ignore_broadcasts = 1;
+int sysctl_icmp_echo_ignore_all __read_mostly;
+int sysctl_icmp_echo_ignore_broadcasts __read_mostly = 1;
 
 /* Control parameter - ignore bogus broadcast responses? */
-int sysctl_icmp_ignore_bogus_error_responses = 1;
+int sysctl_icmp_ignore_bogus_error_responses __read_mostly = 1;
 
 /*
  * 	Configurable global rate limit.
@@ -205,9 +205,9 @@ int sysctl_icmp_ignore_bogus_error_respo
  *	time exceeded (11), parameter problem (12)
  */
 
-int sysctl_icmp_ratelimit = 1 * HZ;
-int sysctl_icmp_ratemask = 0x1818;
-int sysctl_icmp_errors_use_inbound_ifaddr;
+int sysctl_icmp_ratelimit __read_mostly = 1 * HZ;
+int sysctl_icmp_ratemask __read_mostly = 0x1818;
+int sysctl_icmp_errors_use_inbound_ifaddr __read_mostly;
 
 /*
  *	ICMP control array. This specifies what to do with each ICMP.
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index f84c4d0..48d705e 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -1397,8 +1397,8 @@ static struct in_device * ip_mc_find_dev
 /*
  *	Join a socket to a group
  */
-int sysctl_igmp_max_memberships = IP_MAX_MEMBERSHIPS;
-int sysctl_igmp_max_msf = IP_MAX_MSF;
+int sysctl_igmp_max_memberships __read_mostly = IP_MAX_MEMBERSHIPS;
+int sysctl_igmp_max_msf __read_mostly = IP_MAX_MSF;
 
 
 static int ip_mc_del1_src(struct ip_mc_list *pmc, int sfmode,
diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index 8d7f107..165d728 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -54,15 +54,15 @@
  * even the most extreme cases without allowing an attacker to measurably
  * harm machine performance.
  */
-int sysctl_ipfrag_high_thresh = 256*1024;
-int sysctl_ipfrag_low_thresh = 192*1024;
+int sysctl_ipfrag_high_thresh __read_mostly = 256*1024;
+int sysctl_ipfrag_low_thresh __read_mostly = 192*1024;
 
-int sysctl_ipfrag_max_dist = 64;
+int sysctl_ipfrag_max_dist __read_mostly = 64;
 
 /* Important NOTE! Fragment queue must be destroyed before MSL expires.
  * RFC791 is wrong proposing to prolongate timer each fragment arrival by TTL.
  */
-int sysctl_ipfrag_time = IP_FRAG_TIME;
+int sysctl_ipfrag_time __read_mostly = IP_FRAG_TIME;
 
 struct ipfrag_skb_cb
 {
@@ -130,7 +130,7 @@ static unsigned int ipqhashfn(u16 id, u3
 }
 
 static struct timer_list ipfrag_secret_timer;
-int sysctl_ipfrag_secret_interval = 10 * 60 * HZ;
+int sysctl_ipfrag_secret_interval __read_mostly = 10 * 60 * HZ;
 
 static void ipfrag_secret_rebuild(unsigned long dummy)
 {
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 81ee5f7..d6ffe90 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -83,7 +83,7 @@
 #include <linux/netlink.h>
 #include <linux/tcp.h>
 
-int sysctl_ip_default_ttl = IPDEFTTL;
+int sysctl_ip_default_ttl __read_mostly = IPDEFTTL;
 
 /* Generate a checksum for an outgoing IP datagram. */
 __inline__ void ip_send_check(struct iphdr *iph)
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index b0124e6..e570db4 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -268,7 +268,7 @@
 #include <asm/uaccess.h>
 #include <asm/ioctls.h>
 
-int sysctl_tcp_fin_timeout = TCP_FIN_TIMEOUT;
+int sysctl_tcp_fin_timeout __read_mostly = TCP_FIN_TIMEOUT;
 
 DEFINE_SNMP_STAT(struct tcp_mib, tcp_statistics) __read_mostly;
 
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 738dad9..54019b2 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -72,24 +72,24 @@
 #include <asm/unaligned.h>
 #include <net/netdma.h>
 
-int sysctl_tcp_timestamps = 1;
-int sysctl_tcp_window_scaling = 1;
-int sysctl_tcp_sack = 1;
-int sysctl_tcp_fack = 1;
-int sysctl_tcp_reordering = TCP_FASTRETRANS_THRESH;
-int sysctl_tcp_ecn;
-int sysctl_tcp_dsack = 1;
-int sysctl_tcp_app_win = 31;
-int sysctl_tcp_adv_win_scale = 2;
-
-int sysctl_tcp_stdurg;
-int sysctl_tcp_rfc1337;
-int sysctl_tcp_max_orphans = NR_FILE;
-int sysctl_tcp_frto;
-int sysctl_tcp_nometrics_save;
+int sysctl_tcp_timestamps __read_mostly = 1;
+int sysctl_tcp_window_scaling __read_mostly = 1;
+int sysctl_tcp_sack __read_mostly = 1;
+int sysctl_tcp_fack __read_mostly = 1;
+int sysctl_tcp_reordering __read_mostly = TCP_FASTRETRANS_THRESH;
+int sysctl_tcp_ecn __read_mostly;
+int sysctl_tcp_dsack __read_mostly = 1;
+int sysctl_tcp_app_win __read_mostly = 31;
+int sysctl_tcp_adv_win_scale __read_mostly = 2;
+
+int sysctl_tcp_stdurg __read_mostly;
+int sysctl_tcp_rfc1337 __read_mostly;
+int sysctl_tcp_max_orphans __read_mostly = NR_FILE;
+int sysctl_tcp_frto __read_mostly;
+int sysctl_tcp_nometrics_save __read_mostly;
 
-int sysctl_tcp_moderate_rcvbuf = 1;
-int sysctl_tcp_abc = 1;
+int sysctl_tcp_moderate_rcvbuf __read_mostly = 1;
+int sysctl_tcp_abc __read_mostly = 1;
 
 #define FLAG_DATA		0x01 /* Incoming frame contained data.		*/
 #define FLAG_WIN_UPDATE		0x02 /* Incoming ACK was a window update.	*/
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index b2aa512..bd03da8 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -78,8 +78,8 @@
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
 
-int sysctl_tcp_tw_reuse;
-int sysctl_tcp_low_latency;
+int sysctl_tcp_tw_reuse __read_mostly;
+int sysctl_tcp_low_latency __read_mostly;
 
 /* Check TCP sequence numbers in ICMP packets. */
 #define ICMP_MIN_LENGTH 8
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 624e2b2..b2ae1b0 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -34,8 +34,8 @@
 #define SYNC_INIT 1
 #endif
 
-int sysctl_tcp_syncookies = SYNC_INIT; 
-int sysctl_tcp_abort_on_overflow;
+int sysctl_tcp_syncookies __read_mostly = SYNC_INIT; 
+int sysctl_tcp_abort_on_overflow __read_mostly;
 
 struct inet_timewait_death_row tcp_death_row = {
 	.sysctl_max_tw_buckets = NR_FILE * 2,
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index e89cb52..cb94eb8 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -43,24 +43,24 @@
 #include <linux/smp_lock.h>
 
 /* People can turn this off for buggy TCP's found in printers etc. */
-int sysctl_tcp_retrans_collapse = 1;
+int sysctl_tcp_retrans_collapse __read_mostly = 1;
 
 /* People can turn this on to  work with those rare, broken TCPs that
  * interpret the window field as a signed quantity.
  */
-int sysctl_tcp_workaround_signed_windows = 0;
+int sysctl_tcp_workaround_signed_windows __read_mostly = 0;
 
 /* This limits the percentage of the congestion window which we
  * will allow a single TSO frame to consume.  Building TSO frames
  * which are too large can cause TCP streams to be bursty.
  */
-int sysctl_tcp_tso_win_divisor = 3;
+int sysctl_tcp_tso_win_divisor __read_mostly = 3;
 
-int sysctl_tcp_mtu_probing = 0;
-int sysctl_tcp_base_mss = 512;
+int sysctl_tcp_mtu_probing __read_mostly = 0;
+int sysctl_tcp_base_mss __read_mostly = 512;
 
 /* By default, RFC2861 behavior.  */
-int sysctl_tcp_slow_start_after_idle = 1;
+int sysctl_tcp_slow_start_after_idle __read_mostly = 1;
 
 static void update_send_head(struct sock *sk, struct tcp_sock *tp,
 			     struct sk_buff *skb)
diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index 7c1bde3..f6a0586 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -23,14 +23,14 @@
 #include <linux/module.h>
 #include <net/tcp.h>
 
-int sysctl_tcp_syn_retries = TCP_SYN_RETRIES; 
-int sysctl_tcp_synack_retries = TCP_SYNACK_RETRIES; 
-int sysctl_tcp_keepalive_time = TCP_KEEPALIVE_TIME;
-int sysctl_tcp_keepalive_probes = TCP_KEEPALIVE_PROBES;
-int sysctl_tcp_keepalive_intvl = TCP_KEEPALIVE_INTVL;
-int sysctl_tcp_retries1 = TCP_RETR1;
-int sysctl_tcp_retries2 = TCP_RETR2;
-int sysctl_tcp_orphan_retries;
+int sysctl_tcp_syn_retries __read_mostly = TCP_SYN_RETRIES; 
+int sysctl_tcp_synack_retries __read_mostly = TCP_SYNACK_RETRIES; 
+int sysctl_tcp_keepalive_time __read_mostly = TCP_KEEPALIVE_TIME;
+int sysctl_tcp_keepalive_probes __read_mostly = TCP_KEEPALIVE_PROBES;
+int sysctl_tcp_keepalive_intvl __read_mostly = TCP_KEEPALIVE_INTVL;
+int sysctl_tcp_retries1 __read_mostly = TCP_RETR1;
+int sysctl_tcp_retries2 __read_mostly = TCP_RETR2;
+int sysctl_tcp_orphan_retries __read_mostly;
 
 static void tcp_write_timer(unsigned long);
 static void tcp_delack_timer(unsigned long);
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index c96849d..95c71da 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -145,7 +145,7 @@ static int ipv6_chk_same_addr(const stru
 
 static ATOMIC_NOTIFIER_HEAD(inet6addr_chain);
 
-struct ipv6_devconf ipv6_devconf = {
+struct ipv6_devconf ipv6_devconf __read_mostly = {
 	.forwarding		= 0,
 	.hop_limit		= IPV6_DEFAULT_HOPLIMIT,
 	.mtu6			= IPV6_MIN_MTU,
@@ -176,7 +176,7 @@ struct ipv6_devconf ipv6_devconf = {
 #endif
 };
 
-static struct ipv6_devconf ipv6_devconf_dflt = {
+static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
 	.forwarding		= 0,
 	.hop_limit		= IPV6_DEFAULT_HOPLIMIT,
 	.mtu6			= IPV6_MIN_MTU,
@@ -3657,7 +3657,7 @@ static struct addrconf_sysctl_table
 	ctl_table addrconf_conf_dir[2];
 	ctl_table addrconf_proto_dir[2];
 	ctl_table addrconf_root_dir[2];
-} addrconf_sysctl = {
+} addrconf_sysctl __read_mostly = {
 	.sysctl_header = NULL,
 	.addrconf_vars = {
         	{
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 82a1b1a..2ff600c 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -67,7 +67,7 @@ MODULE_AUTHOR("Cast of dozens");
 MODULE_DESCRIPTION("IPv6 protocol stack for Linux");
 MODULE_LICENSE("GPL");
 
-int sysctl_ipv6_bindv6only;
+int sysctl_ipv6_bindv6only __read_mostly;
 
 /* The inetsw table contains everything that inet_create needs to
  * build a new socket.
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 9218584..891acda 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -151,7 +151,7 @@ static int is_ineligible(struct sk_buff 
 	return 0;
 }
 
-static int sysctl_icmpv6_time = 1*HZ; 
+static int sysctl_icmpv6_time __read_mostly = 1*HZ; 
 
 /* 
  * Check the ICMP output rate limit 
diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 9d697d4..cc39ef0 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -171,7 +171,7 @@ static int ip6_mc_leave_src(struct sock 
 
 #define IPV6_MLD_MAX_MSF	64
 
-int sysctl_mld_max_msf = IPV6_MLD_MAX_MSF;
+int sysctl_mld_max_msf __read_mostly = IPV6_MLD_MAX_MSF;
 
 /*
  *	socket join on multicast group
diff --git a/net/ipv6/reassembly.c b/net/ipv6/reassembly.c
index a8623d2..f39bbed 100644
--- a/net/ipv6/reassembly.c
+++ b/net/ipv6/reassembly.c
@@ -53,10 +53,10 @@
 #include <net/ndisc.h>
 #include <net/addrconf.h>
 
-int sysctl_ip6frag_high_thresh = 256*1024;
-int sysctl_ip6frag_low_thresh = 192*1024;
+int sysctl_ip6frag_high_thresh __read_mostly = 256*1024;
+int sysctl_ip6frag_low_thresh __read_mostly = 192*1024;
 
-int sysctl_ip6frag_time = IPV6_FRAG_TIMEOUT;
+int sysctl_ip6frag_time __read_mostly = IPV6_FRAG_TIMEOUT;
 
 struct ip6frag_skb_cb
 {
@@ -152,7 +152,7 @@ static unsigned int ip6qhashfn(u32 id, s
 }
 
 static struct timer_list ip6_frag_secret_timer;
-int sysctl_ip6frag_secret_interval = 10 * 60 * HZ;
+int sysctl_ip6frag_secret_interval __read_mostly = 10 * 60 * HZ;
 
 static void ip6_frag_secret_rebuild(unsigned long dummy)
 {

--------------080505010705000901040706--
