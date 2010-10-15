From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next] rtnetlink: remove rtnl_kill_links
Date: Fri, 15 Oct 2010 08:12:01 -0700
Message-ID: <20101015081201.55eae031@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:34414 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754659Ab0JOPMD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Oct 2010 11:12:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The function rtnl_kill_links is defined but never used.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/include/net/rtnetlink.h	2010-10-02 15:28:38.350854857 +0900
+++ b/include/net/rtnetlink.h	2010-10-02 15:29:42.650840398 +0900
@@ -79,7 +79,6 @@ struct rtnl_link_ops {
 
 extern int	__rtnl_link_register(struct rtnl_link_ops *ops);
 extern void	__rtnl_link_unregister(struct rtnl_link_ops *ops);
-extern void	rtnl_kill_links(struct net *net, struct rtnl_link_ops *ops);
 
 extern int	rtnl_link_register(struct rtnl_link_ops *ops);
 extern void	rtnl_link_unregister(struct rtnl_link_ops *ops);
--- a/net/core/rtnetlink.c	2010-10-02 15:28:38.370839030 +0900
+++ b/net/core/rtnetlink.c	2010-10-02 15:29:42.660839574 +0900
@@ -299,14 +299,6 @@ static void __rtnl_kill_links(struct net
 	unregister_netdevice_many(&list_kill);
 }
 
-void rtnl_kill_links(struct net *net, struct rtnl_link_ops *ops)
-{
-	rtnl_lock();
-	__rtnl_kill_links(net, ops);
-	rtnl_unlock();
-}
-EXPORT_SYMBOL_GPL(rtnl_kill_links);
-
 /**
  * __rtnl_link_unregister - Unregister rtnl_link_ops from rtnetlink.
  * @ops: struct rtnl_link_ops * to unregister
