From: Fengguang Wu <fengguang.wu@intel.com>
Subject: [PATCH net-next] net: ping_check_bind_addr() etc. can be static
Date: Sun, 9 Jun 2013 20:24:26 +0800
Message-ID: <20130609122426.GA2715@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Lorenzo Colitti <lorenzo@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:3333 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751906Ab3FINFV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 9 Jun 2013 09:05:21 -0400
Content-Disposition: inline
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

Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 net/ipv4/ping.c |    6 +++---
 net/ipv6/ping.c |   10 +++++-----
 2 files changed, 8 insertions(+), 8 deletions(-)

--- linux-next.orig/net/ipv4/ping.c	2013-06-09 20:19:41.000000000 +0800
+++ linux-next/net/ipv4/ping.c	2013-06-09 20:20:08.105728488 +0800
@@ -283,7 +283,7 @@ void ping_close(struct sock *sk, long ti
 EXPORT_SYMBOL_GPL(ping_close);
 
 /* Checks the bind address and possibly modifies sk->sk_bound_dev_if. */
-int ping_check_bind_addr(struct sock *sk, struct inet_sock *isk,
+static int ping_check_bind_addr(struct sock *sk, struct inet_sock *isk,
 			 struct sockaddr *uaddr, int addr_len) {
 	struct net *net = sock_net(sk);
 	if (sk->sk_family == AF_INET) {
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
--- linux-next.orig/net/ipv6/ping.c	2013-06-09 20:19:41.000000000 +0800
+++ linux-next/net/ipv6/ping.c	2013-06-09 20:20:11.085728559 +0800
@@ -57,22 +57,22 @@ static struct inet_protosw pingv6_protos
 
 
 /* Compatibility glue so we can support IPv6 when it's compiled as a module */
-int dummy_ipv6_recv_error(struct sock *sk, struct msghdr *msg, int len)
+static int dummy_ipv6_recv_error(struct sock *sk, struct msghdr *msg, int len)
 {
 	return -EAFNOSUPPORT;
 }
-int dummy_ip6_datagram_recv_ctl(struct sock *sk, struct msghdr *msg,
+static int dummy_ip6_datagram_recv_ctl(struct sock *sk, struct msghdr *msg,
 				 struct sk_buff *skb)
 {
 	return -EAFNOSUPPORT;
 }
-int dummy_icmpv6_err_convert(u8 type, u8 code, int *err)
+static int dummy_icmpv6_err_convert(u8 type, u8 code, int *err)
 {
 	return -EAFNOSUPPORT;
 }
-void dummy_ipv6_icmp_error(struct sock *sk, struct sk_buff *skb, int err,
+static void dummy_ipv6_icmp_error(struct sock *sk, struct sk_buff *skb, int err,
 			    __be16 port, u32 info, u8 *payload) {}
-int dummy_ipv6_chk_addr(struct net *net, const struct in6_addr *addr,
+static int dummy_ipv6_chk_addr(struct net *net, const struct in6_addr *addr,
 			const struct net_device *dev, int strict)
 {
 	return 0;
