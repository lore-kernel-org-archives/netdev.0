From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: [PATCH 23/29] net/ipv4: rename net_random() to prandom_u32()
Date: Mon, 24 Dec 2012 11:14:10 +0900
Message-ID: <1356315256-6572-24-git-send-email-akinobu.mita@gmail.com>
References: <1356315256-6572-1-git-send-email-akinobu.mita@gmail.com>
Cc: Akinobu Mita <akinobu.mita@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org, akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f42.google.com ([209.85.160.42]:46587 "EHLO
	mail-pb0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752990Ab2LXCPU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Dec 2012 21:15:20 -0500
In-Reply-To: <1356315256-6572-1-git-send-email-akinobu.mita@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use more preferable function name which implies using a pseudo-random
number generator.

Signed-off-by: Akinobu Mita <akinobu.mita@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Cc: James Morris <jmorris@namei.org>
Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Cc: Patrick McHardy <kaber@trash.net>
Cc: netdev@vger.kernel.org
---
 net/ipv4/devinet.c              | 2 +-
 net/ipv4/igmp.c                 | 6 +++---
 net/ipv4/inet_connection_sock.c | 2 +-
 net/ipv4/udp.c                  | 2 +-
 4 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index cc06a47..e849a5e 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -453,7 +453,7 @@ static int __inet_insert_ifa(struct in_ifaddr *ifa, struct nlmsghdr *nlh,
 	}
 
 	if (!(ifa->ifa_flags & IFA_F_SECONDARY)) {
-		net_srandom(ifa->ifa_local);
+		prandom_seed((__force u32)ifa->ifa_local);
 		ifap = last_primary;
 	}
 
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 736ab70..8506a7c 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -186,7 +186,7 @@ static void igmp_stop_timer(struct ip_mc_list *im)
 /* It must be called with locked im->lock */
 static void igmp_start_timer(struct ip_mc_list *im, int max_delay)
 {
-	int tv = net_random() % max_delay;
+	int tv = prandom_u32() % max_delay;
 
 	im->tm_running = 1;
 	if (!mod_timer(&im->timer, jiffies+tv+2))
@@ -195,7 +195,7 @@ static void igmp_start_timer(struct ip_mc_list *im, int max_delay)
 
 static void igmp_gq_start_timer(struct in_device *in_dev)
 {
-	int tv = net_random() % in_dev->mr_maxdelay;
+	int tv = prandom_u32() % in_dev->mr_maxdelay;
 
 	in_dev->mr_gq_running = 1;
 	if (!mod_timer(&in_dev->mr_gq_timer, jiffies+tv+2))
@@ -204,7 +204,7 @@ static void igmp_gq_start_timer(struct in_device *in_dev)
 
 static void igmp_ifc_start_timer(struct in_device *in_dev, int delay)
 {
-	int tv = net_random() % delay;
+	int tv = prandom_u32() % delay;
 
 	if (!mod_timer(&in_dev->mr_ifc_timer, jiffies+tv+2))
 		in_dev_hold(in_dev);
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection_sock.c
index d0670f0..f43fc82 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -114,7 +114,7 @@ int inet_csk_get_port(struct sock *sk, unsigned short snum)
 again:
 		inet_get_local_port_range(&low, &high);
 		remaining = (high - low) + 1;
-		smallest_rover = rover = net_random() % remaining + low;
+		smallest_rover = rover = prandom_u32() % remaining + low;
 
 		smallest_size = -1;
 		do {
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 79c8dbe..ca6cfbb 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -215,7 +215,7 @@ int udp_lib_get_port(struct sock *sk, unsigned short snum,
 		inet_get_local_port_range(&low, &high);
 		remaining = (high - low) + 1;
 
-		rand = net_random();
+		rand = prandom_u32();
 		first = (((u64)rand * remaining) >> 32) + low;
 		/*
 		 * force rand to be an odd multiple of UDP_HTABLE_SIZE
-- 
1.7.11.7
