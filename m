From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: better pcpu data alignment
Date: Sat, 05 Nov 2011 10:19:28 +0100
Message-ID: <1320484768.16609.22.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:37330 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752064Ab1KEJTd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Nov 2011 05:19:33 -0400
Received: by wyh15 with SMTP id 15so3018954wyh.19
        for <netdev@vger.kernel.org>; Sat, 05 Nov 2011 02:19:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tunnels can force an alignment of their percpu data to reduce number of
cache lines used in fast path, or read in .ndo_get_stats()

percpu_alloc() is a very fine grained allocator, so any small hole will
be used anyway.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/veth.c    |    2 +-
 net/ipv4/ip_gre.c     |    2 +-
 net/ipv4/ipip.c       |    2 +-
 net/ipv6/ip6_tunnel.c |    2 +-
 net/ipv6/sit.c        |    2 +-
 5 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index 5b23767..dd303a9 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -26,8 +26,8 @@
 
 struct veth_net_stats {
 	u64			rx_packets;
-	u64			tx_packets;
 	u64			rx_bytes;
+	u64			tx_packets;
 	u64			tx_bytes;
 	u64			rx_dropped;
 	struct u64_stats_sync	syncp;
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index d55110e..38f7c07 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -171,7 +171,7 @@ struct pcpu_tstats {
 	unsigned long	rx_bytes;
 	unsigned long	tx_packets;
 	unsigned long	tx_bytes;
-};
+} __attribute__((aligned(4*sizeof(unsigned long))));
 
 static struct net_device_stats *ipgre_get_stats(struct net_device *dev)
 {
diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 065effd..9490690 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -148,7 +148,7 @@ struct pcpu_tstats {
 	unsigned long	rx_bytes;
 	unsigned long	tx_packets;
 	unsigned long	tx_bytes;
-};
+} __attribute__((aligned(4*sizeof(unsigned long))));
 
 static struct net_device_stats *ipip_get_stats(struct net_device *dev)
 {
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index bdc15c9..f36ca13 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -93,7 +93,7 @@ struct pcpu_tstats {
 	unsigned long	rx_bytes;
 	unsigned long	tx_packets;
 	unsigned long	tx_bytes;
-};
+} __attribute__((aligned(4*sizeof(unsigned long))));
 
 static struct net_device_stats *ip6_get_stats(struct net_device *dev)
 {
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index a7a1860..cec0938 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -91,7 +91,7 @@ struct pcpu_tstats {
 	unsigned long	rx_bytes;
 	unsigned long	tx_packets;
 	unsigned long	tx_bytes;
-};
+} __attribute__((aligned(4*sizeof(unsigned long))));
 
 static struct net_device_stats *ipip6_get_stats(struct net_device *dev)
 {
