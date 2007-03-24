From: John Heffner <jheffner@psc.edu>
Subject: [PATCH 2/2] [iputils] Use PMTUDISC_PROBE mode if it exists.
Date: Fri, 23 Mar 2007 20:07:22 -0400
Message-ID: <11746948421490-git-send-email-jheffner@psc.edu>
References: <11746948424197-git-send-email-jheffner@psc.edu>
Cc: netdev@vger.kernel.org, John Heffner <jheffner@psc.edu>
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.psc.edu ([128.182.58.100]:59385 "EHLO mailer1.psc.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2992643AbXCXAqq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Mar 2007 20:46:46 -0400
In-Reply-To: <11746948424197-git-send-email-jheffner@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: John Heffner <jheffner@psc.edu>
---
 tracepath.c  |   10 ++++++++--
 tracepath6.c |   10 ++++++++--
 2 files changed, 16 insertions(+), 4 deletions(-)

diff --git a/tracepath.c b/tracepath.c
index 1f901ba..a562d88 100644
--- a/tracepath.c
+++ b/tracepath.c
@@ -24,6 +24,10 @@
 #include <sys/uio.h>
 #include <arpa/inet.h>
 
+#ifndef IP_PMTUDISC_PROBE
+#define IP_PMTUDISC_PROBE	3
+#endif
+
 struct hhistory
 {
 	int	hops;
@@ -322,8 +326,10 @@ main(int argc, char **argv)
 	}
 	memcpy(&target.sin_addr, he->h_addr, 4);
 
-	on = IP_PMTUDISC_DO;
-	if (setsockopt(fd, SOL_IP, IP_MTU_DISCOVER, &on, sizeof(on))) {
+	on = IP_PMTUDISC_PROBE;
+	if (setsockopt(fd, SOL_IP, IP_MTU_DISCOVER, &on, sizeof(on)) &&
+	    (on = IP_PMTUDISC_DO,
+	     setsockopt(fd, SOL_IP, IP_MTU_DISCOVER, &on, sizeof(on)))) {
 		perror("IP_MTU_DISCOVER");
 		exit(1);
 	}
diff --git a/tracepath6.c b/tracepath6.c
index d65230d..6f13a51 100644
--- a/tracepath6.c
+++ b/tracepath6.c
@@ -30,6 +30,10 @@
 #define SOL_IPV6 IPPROTO_IPV6
 #endif
 
+#ifndef IPV6_PMTUDISC_PROBE
+#define IPV6_PMTUDISC_PROBE	3
+#endif
+
 int overhead = 48;
 int mtu = 128000;
 int hops_to = -1;
@@ -369,8 +373,10 @@ int main(int argc, char **argv)
 		mapped = 1;
 	}
 
-	on = IPV6_PMTUDISC_DO;
-	if (setsockopt(fd, SOL_IPV6, IPV6_MTU_DISCOVER, &on, sizeof(on))) {
+	on = IPV6_PMTUDISC_PROBE;
+	if (setsockopt(fd, SOL_IPV6, IPV6_MTU_DISCOVER, &on, sizeof(on)) &&
+	    (on = IPV6_PMTUDISC_DO,
+	     setsockopt(fd, SOL_IPV6, IPV6_MTU_DISCOVER, &on, sizeof(on)))) {
 		perror("IPV6_MTU_DISCOVER");
 		exit(1);
 	}
-- 
1.5.0.2.gc260-dirty

