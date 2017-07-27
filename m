From: Florian Westphal <fw@strlen.de>
Subject: [RFC PATCH net-next 3/6] tcp: remove low_latency sysctl
Date: Fri, 28 Jul 2017 01:31:14 +0200
Message-ID: <20170727233117.29695-4-fw@strlen.de>
References: <20170727233117.29695-1-fw@strlen.de>
Cc: ycheng@google.com, ncardwell@google.com, edumazet@google.com,
        soheil@google.com, weiwan@google.com, brakmo@fb.com,
        Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:38358 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751634AbdG0XbY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Jul 2017 19:31:24 -0400
In-Reply-To: <20170727233117.29695-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

this option was used by the removed prequeue code, it has no effect
anymore.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 Documentation/networking/ip-sysctl.txt | 7 +------
 include/net/tcp.h                      | 1 -
 net/ipv4/sysctl_net_ipv4.c             | 3 +++
 net/ipv4/tcp_ipv4.c                    | 2 --
 4 files changed, 4 insertions(+), 9 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index f485d553e65c..84c9b8cee780 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -353,12 +353,7 @@ tcp_l3mdev_accept - BOOLEAN
 	compiled with CONFIG_NET_L3_MASTER_DEV.
 
 tcp_low_latency - BOOLEAN
-	If set, the TCP stack makes decisions that prefer lower
-	latency as opposed to higher throughput.  By default, this
-	option is not set meaning that higher throughput is preferred.
-	An example of an application where this default should be
-	changed would be a Beowulf compute cluster.
-	Default: 0
+	This is a legacy option, it has no effect anymore.
 
 tcp_max_orphans - INTEGER
 	Maximal number of TCP sockets not attached to any user file handle,
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 93f115cfc8f8..8507c81fb0e9 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -256,7 +256,6 @@ extern int sysctl_tcp_rmem[3];
 extern int sysctl_tcp_app_win;
 extern int sysctl_tcp_adv_win_scale;
 extern int sysctl_tcp_frto;
-extern int sysctl_tcp_low_latency;
 extern int sysctl_tcp_nometrics_save;
 extern int sysctl_tcp_moderate_rcvbuf;
 extern int sysctl_tcp_tso_win_divisor;
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 9bf809726066..0d3c038d7b04 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -45,6 +45,9 @@ static int tcp_syn_retries_max = MAX_TCP_SYNCNT;
 static int ip_ping_group_range_min[] = { 0, 0 };
 static int ip_ping_group_range_max[] = { GID_T_MAX, GID_T_MAX };
 
+/* obsolete */
+static int sysctl_tcp_low_latency __read_mostly;
+
 /* Update system visible IP port range */
 static void set_local_port_range(struct net *net, int range[2])
 {
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index a68eb4577d36..9b51663cd5a4 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -85,8 +85,6 @@
 #include <crypto/hash.h>
 #include <linux/scatterlist.h>
 
-int sysctl_tcp_low_latency __read_mostly;
-
 #ifdef CONFIG_TCP_MD5SIG
 static int tcp_v4_md5_hash_hdr(char *md5_hash, const struct tcp_md5sig_key *key,
 			       __be32 daddr, __be32 saddr, const struct tcphdr *th);
-- 
2.13.0
