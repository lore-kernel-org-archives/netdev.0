From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH [iputils] 5/5] tftpd: check return value of set*id calls
Date: Sat, 19 Apr 2014 10:43:17 -0400
Message-ID: <1397918597-8680-5-git-send-email-vapier@gentoo.org>
References: <1397918597-8680-1-git-send-email-vapier@gentoo.org>
Cc: netdev@vger.kernel.org,
	David Heidelberger <david.heidelberger@ixit.cz>
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:48271 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752115AbaDSOnU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 19 Apr 2014 10:43:20 -0400
In-Reply-To: <1397918597-8680-1-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
 tftpd.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/tftpd.c b/tftpd.c
index 2a39ec4..6519de3 100644
--- a/tftpd.c
+++ b/tftpd.c
@@ -109,17 +109,20 @@ int main(int ac, char **av)
 	register int n = 0;
 	int on = 1;
 
+	openlog("tftpd", LOG_PID, LOG_DAEMON);
+
 	/* Sanity. If parent forgot to setuid() on us. */
 	if (geteuid() == 0) {
-		setgid(65534);
-		setuid(65534);
+		if (setgid(65534) || setuid(65534)) {
+			syslog(LOG_ERR, "set*id failed: %m\n");
+			exit(1);
+		}
 	}
 
 	ac--; av++;
 	while (ac-- > 0 && n < MAXARG)
 		dirs[n++] = *av++;
 
-	openlog("tftpd", LOG_PID, LOG_DAEMON);
 	if (ioctl(0, FIONBIO, &on) < 0) {
 		syslog(LOG_ERR, "ioctl(FIONBIO): %m\n");
 		exit(1);
-- 
1.9.2
