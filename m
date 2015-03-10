From: Fan Du <fan.du@intel.com>
Subject: [PATCH net-next 1/4] ipv4: Rename tcp_mtu_probing to tcp_blackhole_probe
Date: Tue, 10 Mar 2015 17:16:23 +0800
Message-ID: <1425978986-8512-2-git-send-email-fan.du@intel.com>
References: <1425978986-8512-1-git-send-email-fan.du@intel.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	fengyuleidian0615@gmail.com
To: johnwheffner@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:53954 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751945AbbCJJV0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Mar 2015 05:21:26 -0400
In-Reply-To: <1425978986-8512-1-git-send-email-fan.du@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a cosmetic patch by using tcp_blackhole_probe to
clear confusion between tcp_mtu_probing and tcp_mtu_probe.
In essence keep running into tcp_mtu_probing is a sign of
blackhole incident.

Signed-off-by: Fan Du <fan.du@intel.com>
---
 net/ipv4/tcp_timer.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_timer.c b/net/ipv4/tcp_timer.c
index 1550593..abde4e1 100644
--- a/net/ipv4/tcp_timer.c
+++ b/net/ipv4/tcp_timer.c
@@ -99,7 +99,8 @@ static int tcp_orphan_retries(struct sock *sk, int alive)
 	return retries;
 }
 
-static void tcp_mtu_probing(struct inet_connection_sock *icsk, struct sock *sk)
+static void tcp_blackhole_probe(struct inet_connection_sock *icsk,
+				struct sock *sk)
 {
 	struct net *net = sock_net(sk);
 
@@ -177,7 +178,7 @@ static int tcp_write_timeout(struct sock *sk)
 	} else {
 		if (retransmits_timed_out(sk, sysctl_tcp_retries1, 0, 0)) {
 			/* Black hole detection */
-			tcp_mtu_probing(icsk, sk);
+			tcp_blackhole_probe(icsk, sk);
 
 			dst_negative_advice(sk);
 		}
-- 
1.7.1
