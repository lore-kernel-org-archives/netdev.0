From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [PATCH v2 net-next] net: ping_check_bind_addr() etc. can be static
Date: Wed, 12 Jun 2013 21:04:16 +0800
Message-ID: <20130612130416.GA22783@localhost>
References: <20130609122426.GA2715@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Lorenzo Colitti <lorenzo@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:1571 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755355Ab3FLNE0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Jun 2013 09:04:26 -0400
Content-Disposition: inline
In-Reply-To: <20130609122426.GA2715@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

net/ipv4/ping.c:286:5: sparse: symbol 'ping_check_bind_addr' was not declared. Should it be static?
net/ipv4/ping.c:355:6: sparse: symbol 'ping_set_saddr' was not declared. Should it be static?
net/ipv4/ping.c:370:6: sparse: symbol 'ping_clear_saddr' was not declared. Should it be static?

net/ipv6/ping.c:60:5: sparse: symbol 'dummy_ipv6_recv_error' was not declared. Should it be static?
net/ipv6/ping.c:64:5: sparse: symbol 'dummy_ip6_datagram_recv_ctl' was not declared. Should it be static?
net/ipv6/ping.c:69:5: sparse: symbol 'dummy_icmpv6_err_convert' was not declared. Should it be static?
net/ipv6/ping.c:73:6: sparse: symbol 'dummy_ipv6_icmp_error' was not declared. Should it be static?
net/ipv6/ping.c:75:5: sparse: symbol 'dummy_ipv6_chk_addr' was not declared. Should it be static?
net/ipv6/ping.c:201:5: sparse: symbol 'ping_v6_seq_show' was not declared. Should it be static?

Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 net/ipv4/ping.c |    8 ++++----
 net/ipv6/ping.c |   18 +++++++++---------
 2 files changed, 13 insertions(+), 13 deletions(-)

--- linux-next.orig/net/ipv4/ping.c	2013-06-12 17:51:56.880494749 +0800
+++ linux-next/net/ipv4/ping.c	2013-06-12 20:58:16.520760450 +0800
@@ -283,8 +283,8 @@ void ping_close(struct sock *sk, long ti
 EXPORT_SYMBOL_GPL(ping_close);
 
 /* Checks the bind address and possibly modifies sk->sk_bound_dev_if. */
-int ping_check_bind_addr(struct sock *sk, struct inet_sock *isk,
-			 struct sockaddr *uaddr, int addr_len) {
+static int ping_check_bind_addr(struct sock *sk, struct inet_sock *isk,
+				struct sockaddr *uaddr, int addr_len) {
 	struct net *net = sock_net(sk);
 	if (sk->sk_family == AF_INET) {
 		struct sockaddr_in *addr = (struct sockaddr_in *) uaddr;
@@ -352,7 +352,7 @@ int ping_check_bind_addr(struct sock *sk
 	return 0;
 }
 
-void ping_set_saddr(struct sock *sk, struct sockaddr *saddr)
+static void ping_set_saddr(struct sock *sk, struct sockaddr *saddr)
 {
 	if (saddr->sa_family == AF_INET) {
 		struct inet_sock *isk = inet_sk(sk);
@@ -367,7 +367,7 @@ void ping_set_saddr(struct sock *sk, str
 	}
 }
 
-void ping_clear_saddr(struct sock *sk, int dif)
+static void ping_clear_saddr(struct sock *sk, int dif)
 {
 	sk->sk_bound_dev_if = dif;
 	if (sk->sk_family == AF_INET) {
--- linux-next.orig/net/ipv6/ping.c	2013-06-12 18:26:51.696544536 +0800
+++ linux-next/net/ipv6/ping.c	2013-06-12 20:59:13.836761812 +0800
@@ -57,23 +57,23 @@ static struct inet_protosw pingv6_protos
 
 
 /* Compatibility glue so we can support IPv6 when it's compiled as a module */
-int dummy_ipv6_recv_error(struct sock *sk, struct msghdr *msg, int len)
+static int dummy_ipv6_recv_error(struct sock *sk, struct msghdr *msg, int len)
 {
 	return -EAFNOSUPPORT;
 }
-int dummy_ip6_datagram_recv_ctl(struct sock *sk, struct msghdr *msg,
-				 struct sk_buff *skb)
+static int dummy_ip6_datagram_recv_ctl(struct sock *sk, struct msghdr *msg,
+				       struct sk_buff *skb)
 {
 	return -EAFNOSUPPORT;
 }
-int dummy_icmpv6_err_convert(u8 type, u8 code, int *err)
+static int dummy_icmpv6_err_convert(u8 type, u8 code, int *err)
 {
 	return -EAFNOSUPPORT;
 }
-void dummy_ipv6_icmp_error(struct sock *sk, struct sk_buff *skb, int err,
-			    __be16 port, u32 info, u8 *payload) {}
-int dummy_ipv6_chk_addr(struct net *net, const struct in6_addr *addr,
-			const struct net_device *dev, int strict)
+static void dummy_ipv6_icmp_error(struct sock *sk, struct sk_buff *skb, int err,
+				  __be16 port, u32 info, u8 *payload) {}
+static int dummy_ipv6_chk_addr(struct net *net, const struct in6_addr *addr,
+			       const struct net_device *dev, int strict)
 {
 	return 0;
 }
@@ -198,7 +198,7 @@ static void *ping_v6_seq_start(struct se
 	return ping_seq_start(seq, pos, AF_INET6);
 }
 
-int ping_v6_seq_show(struct seq_file *seq, void *v)
+static int ping_v6_seq_show(struct seq_file *seq, void *v)
 {
 	if (v == SEQ_START_TOKEN) {
 		seq_puts(seq, IPV6_SEQ_DGRAM_HEADER);
