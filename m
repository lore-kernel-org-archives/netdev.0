From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Subject: [PATCH iproute2 1/2] libs: close file in netns_switch()
Date: Fri, 14 Aug 2015 02:56:52 +0000
Message-ID: <1439521013-22260-2-git-send-email-zhangshengju@cmss.chinamobile.com>
References: <1439521013-22260-1-git-send-email-zhangshengju@cmss.chinamobile.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta3.chinamobile.com ([221.176.66.81]:9810 "EHLO
	cmccmta3.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754733AbbHNCxo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2015 22:53:44 -0400
In-Reply-To: <1439521013-22260-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add mising close() calls.

Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
---
 lib/namespace.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/lib/namespace.c b/lib/namespace.c
index 8197165..025ed47 100644
--- a/lib/namespace.c
+++ b/lib/namespace.c
@@ -45,7 +45,7 @@ static void bind_etc(const char *name)
 int netns_switch(char *name)
 {
 	char net_path[PATH_MAX];
-	int netns;
+	int netns, ret = -1;
 
 	snprintf(net_path, sizeof(net_path), "%s/%s", NETNS_RUN_DIR, name);
 	netns = open(net_path, O_RDONLY | O_CLOEXEC);
@@ -83,10 +83,10 @@ int netns_switch(char *name)
 
 	/* Setup bind mounts for config files in /etc */
 	bind_etc(name);
-	return 0;
+	ret = 0;
 fail_close:
 	close(netns);
-	return -1;
+	return ret;
 }
 
 int netns_get_fd(const char *name)
-- 
1.8.3.1
