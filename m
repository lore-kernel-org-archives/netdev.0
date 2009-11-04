From: Mike Frysinger <vapier@gentoo.org>
Subject: [PATCH] ifstat/nstat/rtacct: use daemon()
Date: Wed,  4 Nov 2009 09:26:35 -0500
Message-ID: <1257344795-8665-3-git-send-email-vapier@gentoo.org>
References: <1257344795-8665-1-git-send-email-vapier@gentoo.org>
To: stephen.hemminger@vyatta.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.gentoo.org ([140.211.166.183]:46057 "EHLO smtp.gentoo.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756491AbZKDOZS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Nov 2009 09:25:18 -0500
In-Reply-To: <1257344795-8665-1-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A bunch of misc utils basically reimplement the daemon() function (the
whole fork/close/chdir/etc...).  Rather than do that, use daemon() as
that will work under nommu Linux systems that lack fork().

Signed-off-by: Mike Frysinger <vapier@gentoo.org>
---
 misc/ifstat.c |    8 ++++----
 misc/nstat.c  |    8 ++++----
 misc/rtacct.c |    8 ++++----
 3 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/misc/ifstat.c b/misc/ifstat.c
index 68dfdee..0ce8c92 100644
--- a/misc/ifstat.c
+++ b/misc/ifstat.c
@@ -663,10 +663,10 @@ int main(int argc, char *argv[])
 			perror("ifstat: listen");
 			exit(-1);
 		}
-		if (fork())
-			exit(0);
-		chdir("/");
-		close(0); close(1); close(2); setsid();
+		if (daemon(0, 0)) {
+			perror("ifstat: daemon");
+			exit(-1);
+		}
 		signal(SIGPIPE, SIG_IGN);
 		signal(SIGCHLD, sigchild);
 		server_loop(fd);
diff --git a/misc/nstat.c b/misc/nstat.c
index 80e695f..2e44ed2 100644
--- a/misc/nstat.c
+++ b/misc/nstat.c
@@ -513,10 +513,10 @@ int main(int argc, char *argv[])
 			perror("nstat: listen");
 			exit(-1);
 		}
-		if (fork())
-			exit(0);
-		chdir("/");
-		close(0); close(1); close(2); setsid();
+		if (daemon(0, 0)) {
+			perror("nstat: daemon");
+			exit(-1);
+		}
 		signal(SIGPIPE, SIG_IGN);
 		signal(SIGCHLD, sigchild);
 		server_loop(fd);
diff --git a/misc/rtacct.c b/misc/rtacct.c
index eb3ea9e..a247dfd 100644
--- a/misc/rtacct.c
+++ b/misc/rtacct.c
@@ -524,10 +524,10 @@ int main(int argc, char *argv[])
 			perror("rtacct: listen");
 			exit(-1);
 		}
-		if (fork())
-			exit(0);
-		chdir("/");
-		close(0); close(1); close(2); setsid();
+		if (daemon(0, 0)) {
+			perror("rtacct: daemon");
+			exit(-1);
+		}
 		signal(SIGPIPE, SIG_IGN);
 		signal(SIGCHLD, sigchild);
 		server_loop(fd);
-- 
1.6.5.1

