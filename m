From: Thomas Graf <tgraf@suug.ch>
Subject: [GENETLINK]: Fix adjustment of number of multicast groups
Date: Tue, 24 Jul 2007 11:45:14 +0200
Message-ID: <20070724094514.GD9285@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: johannes@sipsolutions.net, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:59470 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935195AbXGXJox (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jul 2007 05:44:53 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The current calculation of the maximum number of genetlink
multicast groups seems odd, fix it.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6/net/netlink/genetlink.c
===================================================================
--- net-2.6.orig/net/netlink/genetlink.c	2007-07-23 22:03:02.000000000 +0200
+++ net-2.6/net/netlink/genetlink.c	2007-07-23 22:05:12.000000000 +0200
@@ -184,7 +184,7 @@ int genl_register_mc_group(struct genl_f
 	}
 
 	err = netlink_change_ngroups(genl_sock,
-				     sizeof(unsigned long) * NETLINK_GENERIC);
+				     mc_groups_longs * BITS_PER_LONG);
 	if (err)
 		goto out;
 
