From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [PATCH 21/24] sysctl: ipv6: register addrconf tables as private children
Date: Sat,  2 Apr 2011 04:53:35 +0200
Message-ID: <89845283d0ed5cfbb63b2b3b5a1f52e425d239d6.1301711868.git.lucian.grijincu__1383.40779017216$1301712973$gmane$org@gmail.com>
References: <cover.1301711868.git.lucian.grijincu@gmail.com>
Cc: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
To: "'David S . Miller'" <davem@davemloft.net>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	"Eric W . Biederman" <ebiederm@xmission.com>,
	Octavian Purdila <tavi@cs.pub.ro>,
	linux-kernel@vger.
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:32917 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757251Ab1DBCzA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2011 22:55:00 -0400
In-Reply-To: <cover.1301711868.git.lucian.grijincu@gmail.com>
In-Reply-To: <cover.1301711868.git.lucian.grijincu@gmail.com>
References: <cover.1301711868.git.lucian.grijincu@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This halves the time it takes to add an interface:

$ time modprobe dummy numdummies=$n

Without this patch:
 - n=5000 => real:  9:14m, sys: 8:46m
 - n=2000 => real:  1:19m, sys: 1:17m
 - n=1000 => real:  0:14m, sys: 0:14m

With this patch:
 - n=5000 => real:  4:43m, sys: 4:32m
 - n=2000 => real:  0:39m, sys: 0:39m
 - n=1000 => real:  0:07m, sys: 0:07m

Signed-off-by: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
---
 net/ipv6/addrconf.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 6833fcb..6ac29d0 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -4512,8 +4512,8 @@ static int __addrconf_sysctl_register(struct net *net, char *dev_name,
 
 	addrconf_ctl_path[ADDRCONF_CTL_PATH_DEV].procname = t->dev_name;
 
-	t->sysctl_header = register_net_sysctl_table(net, addrconf_ctl_path,
-			t->addrconf_vars);
+	t->sysctl_header = register_net_sysctl_table_with_parent(net,
+	        addrconf_ctl_path, t->addrconf_vars, net->ipv6.sysctl.conf_hdr);
 	if (t->sysctl_header == NULL)
 		goto free_procname;
 
-- 
1.7.5.rc0

