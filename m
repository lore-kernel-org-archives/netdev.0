From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [PATCH 01/24] sysctl: net: call unregister_net_sysctl_table where needed
Date: Sat,  2 Apr 2011 04:53:15 +0200
Message-ID: <05ae3c2fdd2db1f6a2fd3cd900164667e615f4f8.1301711868.git.lucian.grijincu__31658.0923543826$1301713285$gmane$org@gmail.com>
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
	with ESMTP id S1753134Ab1DBCyC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2011 22:54:02 -0400
In-Reply-To: <cover.1301711868.git.lucian.grijincu@gmail.com>
In-Reply-To: <cover.1301711868.git.lucian.grijincu@gmail.com>
References: <cover.1301711868.git.lucian.grijincu@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ctl_table_headers registered with register_net_sysctl_table should
have been unregistered with the equivalent unregister_net_sysctl_table

Signed-off-by: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
---
 net/ipv4/devinet.c  |    2 +-
 net/ipv6/addrconf.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 5345b0b..cd9ca08 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1680,7 +1680,7 @@ static void __devinet_sysctl_unregister(struct ipv4_devconf *cnf)
 		return;
 
 	cnf->sysctl = NULL;
-	unregister_sysctl_table(t->sysctl_header);
+	unregister_net_sysctl_table(t->sysctl_header);
 	kfree(t->dev_name);
 	kfree(t);
 }
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 3daaf3c..b1654a4 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -4537,7 +4537,7 @@ static void __addrconf_sysctl_unregister(struct ipv6_devconf *p)
 
 	t = p->sysctl;
 	p->sysctl = NULL;
-	unregister_sysctl_table(t->sysctl_header);
+	unregister_net_sysctl_table(t->sysctl_header);
 	kfree(t->dev_name);
 	kfree(t);
 }
-- 
1.7.5.rc0

