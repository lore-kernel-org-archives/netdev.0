From: David Ahern <dsahern@gmail.com>
Subject: [PATCH net-next] net: Add comment that early_demux can change via sysctl
Date: Mon, 28 Aug 2017 15:14:20 -0700
Message-ID: <1503958460-20765-1-git-send-email-dsahern@gmail.com>
Cc: David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:33754 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751207AbdH1WOb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Aug 2017 18:14:31 -0400
Received: by mail-pg0-f65.google.com with SMTP id m15so1298941pgc.0
        for <netdev@vger.kernel.org>; Mon, 28 Aug 2017 15:14:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Twice patches trying to constify inet{6}_protocol have been reverted:
39294c3df2a8 ("Revert "ipv6: constify inet6_protocol structures"") to
revert 3a3a4e3054137 and then 03157937fe0b5 ("Revert "ipv4: make
net_protocol const"") to revert aa8db499ea67.

Add a comment that the structures can not be const because the
early_demux field can change based on a sysctl.

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 net/ipv4/af_inet.c  | 6 ++++++
 net/ipv6/tcp_ipv6.c | 3 +++
 net/ipv6/udp.c      | 3 +++
 3 files changed, 12 insertions(+)

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index d678820e4306..e31108e5ef79 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1596,6 +1596,9 @@ static const struct net_protocol igmp_protocol = {
 };
 #endif
 
+/* thinking of making this const? Don't.
+ * early_demux can change based on sysctl.
+ */
 static struct net_protocol tcp_protocol = {
 	.early_demux	=	tcp_v4_early_demux,
 	.early_demux_handler =  tcp_v4_early_demux,
@@ -1606,6 +1609,9 @@ static struct net_protocol tcp_protocol = {
 	.icmp_strict_tag_validation = 1,
 };
 
+/* thinking of making this const? Don't.
+ * early_demux can change based on sysctl.
+ */
 static struct net_protocol udp_protocol = {
 	.early_demux =	udp_v4_early_demux,
 	.early_demux_handler =	udp_v4_early_demux,
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index abba3bc2a3d9..38f76d8b231e 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1949,6 +1949,9 @@ struct proto tcpv6_prot = {
 	.diag_destroy		= tcp_abort,
 };
 
+/* thinking of making this const? Don't.
+ * early_demux can change based on sysctl.
+ */
 static struct inet6_protocol tcpv6_protocol = {
 	.early_demux	=	tcp_v6_early_demux,
 	.early_demux_handler =  tcp_v6_early_demux,
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 2a15f1bb6ef8..976f30391356 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -1472,6 +1472,9 @@ int compat_udpv6_getsockopt(struct sock *sk, int level, int optname,
 }
 #endif
 
+/* thinking of making this const? Don't.
+ * early_demux can change based on sysctl.
+ */
 static struct inet6_protocol udpv6_protocol = {
 	.early_demux	=	udp_v6_early_demux,
 	.early_demux_handler =  udp_v6_early_demux,
-- 
2.1.4
