From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH iputils] tftpd: fix syslog setup
Date: Fri, 24 Apr 2015 23:38:57 -0400
Message-ID: <1429933137-11380-1-git-send-email-vapier@gentoo.org>
Cc: netdev@vger.kernel.org,
	David Heidelberger <david.heidelberger@ixit.cz>
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:46745 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932372AbbDXXjB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Apr 2015 19:39:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit d81a44625b04d487c895473aa77af13420b7afdd added support for checking
the set*id calls, but would call syslog() before it had called openlog().
Move the call up earlier to fix that.

Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
 tftpd.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/tftpd.c b/tftpd.c
index e3af2f4..7ddc8eb 100644
--- a/tftpd.c
+++ b/tftpd.c
@@ -109,6 +109,8 @@ int main(int ac, char **av)
 	register int n = 0;
 	int on = 1;
 
+	openlog("tftpd", LOG_PID, LOG_DAEMON);
+
 	/* Sanity. If parent forgot to setuid() on us. */
 	if (geteuid() == 0) {
 		if (setgid(65534)) {
@@ -125,7 +127,6 @@ int main(int ac, char **av)
 	while (ac-- > 0 && n < MAXARG)
 		dirs[n++] = *av++;
 
-	openlog("tftpd", LOG_PID, LOG_DAEMON);
 	if (ioctl(0, FIONBIO, &on) < 0) {
 		syslog(LOG_ERR, "ioctl(FIONBIO): %m\n");
 		exit(1);
-- 
2.3.5
