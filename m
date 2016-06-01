From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH iputils 5/6] tftpd: fix syslog setup
Date: Tue, 31 May 2016 23:48:24 -0400
Message-ID: <1464752905-10347-5-git-send-email-vapier@gentoo.org>
References: <1464752905-10347-1-git-send-email-vapier@gentoo.org>
Cc: netdev@vger.kernel.org
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:58834 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755697AbcFADsb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 May 2016 23:48:31 -0400
In-Reply-To: <1464752905-10347-1-git-send-email-vapier@gentoo.org>
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
2.8.2
