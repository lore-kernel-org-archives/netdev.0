From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next] ipv6: Export nd_tbl to allow modules to support IPv6
Date: Wed,  5 Sep 2012 13:14:08 +0200
Message-ID: <fd8b9a9ad300edfc378065ef7887c3debeeb5e89.1346843399.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59665 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758599Ab2IELOL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Sep 2012 07:14:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Several out of the tree modules use the exported symbol arp_tbl
to read the ARP table. These modules now seek to support IPv6
but can't because nd_tbl is not exported.

Having access to the protocol specific neigh_table structure is
required in order to use the functions neigh_lookup() or
neigh_create() which are already exported to modules.

It does not make sense to export these functions if we don't
export the table itself as well.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 net/ipv6/ndisc.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
index ff36194..0a0eb3f 100644
--- a/net/ipv6/ndisc.c
+++ b/net/ipv6/ndisc.c
@@ -143,6 +143,8 @@ struct neigh_table nd_tbl = {
 	.gc_thresh3 =	1024,
 };
 
+EXPORT_SYMBOL(nd_tbl);
+
 static inline int ndisc_opt_addr_space(struct net_device *dev)
 {
 	return NDISC_OPT_SPACE(dev->addr_len + ndisc_addr_option_pad(dev->type));
-- 
1.7.11.4
