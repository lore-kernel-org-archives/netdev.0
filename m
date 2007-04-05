From: Thomas Graf <tgraf@suug.ch>
Subject: [RTNL]: Improve error codes for unsupported operations
Date: Thu, 5 Apr 2007 16:34:02 +0200
Message-ID: <20070405143402.GY521@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:58211 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753134AbXDEOdm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Apr 2007 10:33:42 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The most common trigger of these errors is that the
config option hasn't been enable wich would make the
functionality available. Therefore returning EOPNOTSUPP
gives a better idea on what is going wrong.

Signed-off-by: Thomas Graf <tgraf@suug.ch>

Index: net-2.6.22/net/core/rtnetlink.c
===================================================================
--- net-2.6.22.orig/net/core/rtnetlink.c	2007-04-05 13:22:14.000000000 +0200
+++ net-2.6.22/net/core/rtnetlink.c	2007-04-05 13:22:51.000000000 +0200
@@ -861,7 +861,7 @@ static int rtnetlink_rcv_msg(struct sk_b
 
 	type = nlh->nlmsg_type;
 	if (type > RTM_MAX)
-		return -EINVAL;
+		return -EOPNOTSUPP;
 
 	type -= RTM_BASE;
 
@@ -884,7 +884,7 @@ static int rtnetlink_rcv_msg(struct sk_b
 
 		dumpit = rtnl_get_dumpit(family, type);
 		if (dumpit == NULL)
-			return -EINVAL;
+			return -EOPNOTSUPP;
 
 		return netlink_dump_start(rtnl, skb, nlh, dumpit, NULL);
 	}
@@ -912,7 +912,7 @@ static int rtnetlink_rcv_msg(struct sk_b
 
 	doit = rtnl_get_doit(family, type);
 	if (doit == NULL)
-		return -EINVAL;
+		return -EOPNOTSUPP;
 
 	return doit(skb, nlh, (void *)&rta_buf[0]);
 }
