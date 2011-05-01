From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [PATCH] sysctl: net: call unregister_net_sysctl_table where needed
Date: Sun,  1 May 2011 13:44:01 +0200
Message-ID: <1304250241-26138-1-git-send-email-lucian.grijincu@gmail.com>
Cc: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:59821 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753619Ab1EALoP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 May 2011 07:44:15 -0400
Received: by wya21 with SMTP id 21so3681742wya.19
        for <netdev@vger.kernel.org>; Sun, 01 May 2011 04:44:14 -0700 (PDT)
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
index 1493534..a7bda07 100644
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
1.7.5.134.g1c08b

