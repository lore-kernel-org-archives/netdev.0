From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Subject: [PATCH iproute2 2/2] netns: add missing file close
Date: Fri, 14 Aug 2015 02:56:53 +0000
Message-ID: <1439521013-22260-3-git-send-email-zhangshengju@cmss.chinamobile.com>
References: <1439521013-22260-1-git-send-email-zhangshengju@cmss.chinamobile.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta3.chinamobile.com ([221.176.66.81]:9811 "EHLO
	cmccmta3.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754797AbbHNCyU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2015 22:54:20 -0400
In-Reply-To: <1439521013-22260-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add missing file close.

Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
---
 ip/ipnetns.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/ip/ipnetns.c b/ip/ipnetns.c
index 088096f..d1af0c6 100644
--- a/ip/ipnetns.c
+++ b/ip/ipnetns.c
@@ -462,8 +462,10 @@ static int netns_pids(int argc, char **argv)
 	if (fstat(netns, &netst) < 0) {
 		fprintf(stderr, "Stat of netns failed: %s\n",
 			strerror(errno));
+		close(netns);
 		return -1;
 	}
+	close(netns);
 	dir = opendir("/proc/");
 	if (!dir) {
 		fprintf(stderr, "Open of /proc failed: %s\n",
@@ -522,8 +524,10 @@ static int netns_identify(int argc, char **argv)
 	if (fstat(netns, &netst) < 0) {
 		fprintf(stderr, "Stat of netns failed: %s\n",
 			strerror(errno));
+		close(netns);
 		return -1;
 	}
+	close(netns);
 	dir = opendir(NETNS_RUN_DIR);
 	if (!dir) {
 		/* Succeed treat a missing directory as an empty directory */
@@ -728,6 +732,7 @@ static int netns_set(int argc, char **argv)
 			name, strerror(errno));
 		return -1;
 	}
+	close(netns);
 
 	return set_netnsid_from_name(name, nsid);
 }
-- 
1.8.3.1
