From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [PATCH 19/24] sysctl: ipv4: register devinet tables as private children
Date: Sat,  2 Apr 2011 04:53:33 +0200
Message-ID: <8194561cfef6eec0ea462ef2e8e77546a226b499.1301711868.git.lucian.grijincu__6341.58663820035$1301713006$gmane$org@gmail.com>
References: <cover.1301711868.git.lucian.grijincu@gmail.com>
Cc: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
To: "'David S . Miller'" <davem@davemloft.net>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	"Eric W . Biederman" <ebiederm@xmission.com>,
	Octavian Purdila <tavi@cs.pub.ro>,
	linux-kernel@vger.
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:40187 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756990Ab1DBCyz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2011 22:54:55 -0400
In-Reply-To: <cover.1301711868.git.lucian.grijincu@gmail.com>
In-Reply-To: <cover.1301711868.git.lucian.grijincu@gmail.com>
References: <cover.1301711868.git.lucian.grijincu@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This halves the time it takes to add an interface:

$ time modprobe dummy numdummies=$n

Without this patch:
 - n=5000 => real: 17:31m, sys 15:29m
 - n=2000 => real:  2:23m, sys  2:19m
 - n=1000 => real:  0:25m, sys  0:24m

With this patch:
 - n=5000 => real:  9:14m, sys: 8:46m
 - n=2000 => real:  1:19m, sys: 1:17m
 - n=1000 => real:  0:14m, sys: 0:14m

Signed-off-by: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
---
 net/ipv4/devinet.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index a31cc90..2a10365 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1656,8 +1656,8 @@ static int __devinet_sysctl_register(struct net *net, char *dev_name,
 
 	devinet_ctl_path[DEVINET_CTL_PATH_DEV].procname = t->dev_name;
 
-	t->sysctl_header = register_net_sysctl_table(net, devinet_ctl_path,
-			t->devinet_vars);
+	t->sysctl_header = register_net_sysctl_table_with_parent(net,
+			 devinet_ctl_path, t->devinet_vars, net->ipv4.conf_hdr);
 	if (!t->sysctl_header)
 		goto free_procname;
 
-- 
1.7.5.rc0

