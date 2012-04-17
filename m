From: James Chapman <jchapman@katalix.com>
Subject: [RFC PATCH 1/2] ipv6: Export ipv6 functions for use by other protocols
Date: Tue, 17 Apr 2012 13:29:25 +0100
Message-ID: <1334665766-11461-2-git-send-email-jchapman@katalix.com>
References: <y>
Cc: bcrl@kvack.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:52699 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932110Ab2DQM3e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Apr 2012 08:29:34 -0400
In-Reply-To: <y>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For implementing other protocols on top of IPv6, such as L2TPv3's IP
encapsulation over ipv6, we'd like to call some IPv6 functions which
are not currently exported.
---
 net/ipv6/datagram.c      |    4 ++++
 net/ipv6/exthdrs.c       |    1 +
 net/ipv6/ip6_flowlabel.c |    1 +
 net/ipv6/ip6_output.c    |    3 +++
 4 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index 7fba35a..b8b61ac 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -22,6 +22,7 @@
 #include <linux/ipv6.h>
 #include <linux/route.h>
 #include <linux/slab.h>
+#include <linux/export.h>
 
 #include <net/ipv6.h>
 #include <net/ndisc.h>
@@ -202,6 +203,7 @@ out:
 	fl6_sock_release(flowlabel);
 	return err;
 }
+EXPORT_SYMBOL_GPL(ip6_datagram_connect);
 
 void ipv6_icmp_error(struct sock *sk, struct sk_buff *skb, int err,
 		     __be16 port, u32 info, u8 *payload)
@@ -414,6 +416,7 @@ out_free_skb:
 out:
 	return err;
 }
+EXPORT_SYMBOL_GPL(ipv6_recv_error);
 
 /*
  *	Handle IPV6_RECVPATHMTU
@@ -868,3 +871,4 @@ int datagram_send_ctl(struct net *net, struct sock *sk,
 exit_f:
 	return err;
 }
+EXPORT_SYMBOL_GPL(datagram_send_ctl);
diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
index aa0a51e..a93bd23 100644
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -883,6 +883,7 @@ struct ipv6_txoptions *ipv6_fixup_options(struct ipv6_txoptions *opt_space,
 
 	return opt;
 }
+EXPORT_SYMBOL_GPL(ipv6_fixup_options);
 
 /**
  * fl6_update_dst - update flowi destination address with info given
diff --git a/net/ipv6/ip6_flowlabel.c b/net/ipv6/ip6_flowlabel.c
index 1dd6329..cb43df6 100644
--- a/net/ipv6/ip6_flowlabel.c
+++ b/net/ipv6/ip6_flowlabel.c
@@ -294,6 +294,7 @@ struct ipv6_txoptions *fl6_merge_options(struct ipv6_txoptions * opt_space,
 	opt_space->opt_flen = fopt->opt_flen;
 	return opt_space;
 }
+EXPORT_SYMBOL_GPL(fl6_merge_options);
 
 static unsigned long check_linger(unsigned long ttl)
 {
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index b7ca461..2a16aa9 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1535,6 +1535,7 @@ error:
 	IP6_INC_STATS(sock_net(sk), rt->rt6i_idev, IPSTATS_MIB_OUTDISCARDS);
 	return err;
 }
+EXPORT_SYMBOL_GPL(ip6_append_data);
 
 static void ip6_cork_release(struct inet_sock *inet, struct ipv6_pinfo *np)
 {
@@ -1638,6 +1639,7 @@ error:
 	IP6_INC_STATS(net, rt->rt6i_idev, IPSTATS_MIB_OUTDISCARDS);
 	goto out;
 }
+EXPORT_SYMBOL_GPL(ip6_push_pending_frames);
 
 void ip6_flush_pending_frames(struct sock *sk)
 {
@@ -1652,3 +1654,4 @@ void ip6_flush_pending_frames(struct sock *sk)
 
 	ip6_cork_release(inet_sk(sk), inet6_sk(sk));
 }
+EXPORT_SYMBOL_GPL(ip6_flush_pending_frames);
-- 
1.7.0.4
