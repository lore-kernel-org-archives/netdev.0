From: Thomas Graf <tgraf@suug.ch>
Subject: [NET]: Fix typo causing wrong skb to be freed
Date: Thu, 31 Aug 2006 23:26:51 +0200
Message-ID: <20060831212650.GG3470@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:55426 "EHLO postel.suug.ch")
	by vger.kernel.org with ESMTP id S1750823AbWHaV0a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2006 17:26:30 -0400
To: davem@davemloft.net
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A typo introduced by myself which leads to freeing the skb
containing the netlink message when it should free the newly
allocated skb for the reply.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.19/net/core/rtnetlink.c
===================================================================
--- net-2.6.19.orig/net/core/rtnetlink.c	2006-08-30 13:14:48.000000000 +0200
+++ net-2.6.19/net/core/rtnetlink.c	2006-08-31 23:21:28.000000000 +0200
@@ -596,7 +596,7 @@
 	err = rtnl_fill_ifinfo(nskb, dev, iw, iw_buf_len, RTM_NEWLINK,
 			       NETLINK_CB(skb).pid, nlh->nlmsg_seq, 0, 0);
 	if (err <= 0) {
-		kfree_skb(skb);
+		kfree_skb(nskb);
 		goto errout;
 	}
 
