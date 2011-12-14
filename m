From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: ping: remove some sparse errors
Date: Wed, 14 Dec 2011 14:51:28 +0100
Message-ID: <1323870688.2334.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:50720 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755203Ab1LNNvc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Dec 2011 08:51:32 -0500
Received: by mail-ee0-f46.google.com with SMTP id c4so804521eek.19
        for <netdev@vger.kernel.org>; Wed, 14 Dec 2011 05:51:31 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

net/ipv4/sysctl_net_ipv4.c:78:6: warning: symbol 'inet_get_ping_group_range_table'
was not declared. Should it be static?

net/ipv4/sysctl_net_ipv4.c:119:31: warning: incorrect type in argument 2
(different signedness)
net/ipv4/sysctl_net_ipv4.c:119:31: expected int *range
net/ipv4/sysctl_net_ipv4.c:119:31: got unsigned int *<noident>

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/sysctl_net_ipv4.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index fe9bf91..4aa7e9d 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -75,7 +75,7 @@ static int ipv4_local_port_range(ctl_table *table, int write,
 }
 
 
-void inet_get_ping_group_range_table(struct ctl_table *table, gid_t *low, gid_t *high)
+static void inet_get_ping_group_range_table(struct ctl_table *table, gid_t *low, gid_t *high)
 {
 	gid_t *data = table->data;
 	unsigned seq;
@@ -88,7 +88,7 @@ void inet_get_ping_group_range_table(struct ctl_table *table, gid_t *low, gid_t
 }
 
 /* Update system visible IP port range */
-static void set_ping_group_range(struct ctl_table *table, int range[2])
+static void set_ping_group_range(struct ctl_table *table, gid_t range[2])
 {
 	gid_t *data = table->data;
 	write_seqlock(&sysctl_local_ports.lock);
