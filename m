From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH -next] net namespace: build when SYSCTL=n
Date: Fri, 18 Jul 2008 17:18:12 -0700
Message-ID: <20080718171812.8dfc9767.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: lkml <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:34982 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752034AbYGSASi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jul 2008 20:18:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>

When CONFIG_SYSCTL=n, build fails with:

linux-next-20080718/include/net/net_namespace.h:40: error: field 'sysctls' has incomplete type

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 include/net/net_namespace.h |    2 ++
 1 file changed, 2 insertions(+)

--- linux-next-20080718.orig/include/net/net_namespace.h
+++ linux-next-20080718/include/net/net_namespace.h
@@ -37,7 +37,9 @@ struct net {
 	struct proc_dir_entry 	*proc_net;
 	struct proc_dir_entry 	*proc_net_stat;
 
+#ifdef CONFIG_SYSCTL
 	struct ctl_table_set	sysctls;
+#endif
 
 	struct net_device       *loopback_dev;          /* The loopback */
 


---
~Randy
Linux Plumbers Conference, 17-19 September 2008, Portland, Oregon USA
http://linuxplumbersconf.org/
