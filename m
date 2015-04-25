From: Felix Janda <felix.janda@posteo.de>
Subject: [PATCH iproute2] Use PATH_MAX instead of MAXPATHLEN
Date: Sat, 25 Apr 2015 22:33:28 +0200
Message-ID: <20150425203327.GA9433@euler>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx02.posteo.de ([89.146.194.165]:48065 "EHLO mx02.posteo.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751429AbbDYUdf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 Apr 2015 16:33:35 -0400
Received: from dovecot03.posteo.de (unknown [185.67.36.28])
	by mx02.posteo.de (Postfix) with ESMTPS id B3F8E25AF503
	for <netdev@vger.kernel.org>; Sat, 25 Apr 2015 22:33:33 +0200 (CEST)
Received: from mail.posteo.de (localhost [127.0.0.1])
	by dovecot03.posteo.de (Postfix) with ESMTPSA id 3lZ3ws3cKkz5vMw
	for <netdev@vger.kernel.org>; Sat, 25 Apr 2015 22:33:33 +0200 (CEST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

They are equivalent but the former is more common. PATH_MAX is
specified by POSIX and needs <limits.h> while MAXPATHLEN has BSD
origin and needs <sys/param.h>.

PATH_MAX has already been in use in misc/lnstat.h.

Signed-off-by: Felix Janda <felix.janda@posteo.de>
---
 ip/ipnetns.c    | 15 +++++++--------
 lib/namespace.c | 11 ++++++-----
 2 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/ip/ipnetns.c b/ip/ipnetns.c
index 438d59b..c7b45a3 100644
--- a/ip/ipnetns.c
+++ b/ip/ipnetns.c
@@ -4,7 +4,6 @@
 #include <sys/wait.h>
 #include <sys/inotify.h>
 #include <sys/mount.h>
-#include <sys/param.h>
 #include <sys/syscall.h>
 #include <stdio.h>
 #include <string.h>
@@ -436,7 +435,7 @@ static int is_pid(const char *str)
 static int netns_pids(int argc, char **argv)
 {
 	const char *name;
-	char net_path[MAXPATHLEN];
+	char net_path[PATH_MAX];
 	int netns;
 	struct stat netst;
 	DIR *dir;
@@ -471,7 +470,7 @@ static int netns_pids(int argc, char **argv)
 		return -1;
 	}
 	while((entry = readdir(dir))) {
-		char pid_net_path[MAXPATHLEN];
+		char pid_net_path[PATH_MAX];
 		struct stat st;
 		if (!is_pid(entry->d_name))
 			continue;
@@ -492,7 +491,7 @@ static int netns_pids(int argc, char **argv)
 static int netns_identify(int argc, char **argv)
 {
 	const char *pidstr;
-	char net_path[MAXPATHLEN];
+	char net_path[PATH_MAX];
 	int netns;
 	struct stat netst;
 	DIR *dir;
@@ -536,7 +535,7 @@ static int netns_identify(int argc, char **argv)
 	}
 
 	while((entry = readdir(dir))) {
-		char name_path[MAXPATHLEN];
+		char name_path[PATH_MAX];
 		struct stat st;
 
 		if (strcmp(entry->d_name, ".") == 0)
@@ -562,7 +561,7 @@ static int netns_identify(int argc, char **argv)
 
 static int on_netns_del(char *nsname, void *arg)
 {
-	char netns_path[MAXPATHLEN];
+	char netns_path[PATH_MAX];
 
 	snprintf(netns_path, sizeof(netns_path), "%s/%s", NETNS_RUN_DIR, nsname);
 	umount2(netns_path, MNT_DETACH);
@@ -611,7 +610,7 @@ static int netns_add(int argc, char **argv)
 	 * userspace tweaks like remounting /sys, or bind mounting
 	 * a new /etc/resolv.conf can be shared between uers.
 	 */
-	char netns_path[MAXPATHLEN];
+	char netns_path[PATH_MAX];
 	const char *name;
 	int fd;
 	int made_netns_run_dir_mount = 0;
@@ -706,7 +705,7 @@ static int set_netnsid_from_name(const char *name, int nsid)
 
 static int netns_set(int argc, char **argv)
 {
-	char netns_path[MAXPATHLEN];
+	char netns_path[PATH_MAX];
 	const char *name;
 	int netns, nsid;
 
diff --git a/lib/namespace.c b/lib/namespace.c
index c03a103..a61feb6 100644
--- a/lib/namespace.c
+++ b/lib/namespace.c
@@ -9,15 +9,16 @@
 
 #include <fcntl.h>
 #include <dirent.h>
+#include <limits.h>
 
 #include "utils.h"
 #include "namespace.h"
 
 static void bind_etc(const char *name)
 {
-	char etc_netns_path[MAXPATHLEN];
-	char netns_name[MAXPATHLEN];
-	char etc_name[MAXPATHLEN];
+	char etc_netns_path[PATH_MAX];
+	char netns_name[PATH_MAX];
+	char etc_name[PATH_MAX];
 	struct dirent *entry;
 	DIR *dir;
 
@@ -43,7 +44,7 @@ static void bind_etc(const char *name)
 
 int netns_switch(char *name)
 {
-	char net_path[MAXPATHLEN];
+	char net_path[PATH_MAX];
 	int netns;
 
 	snprintf(net_path, sizeof(net_path), "%s/%s", NETNS_RUN_DIR, name);
@@ -87,7 +88,7 @@ int netns_switch(char *name)
 
 int netns_get_fd(const char *name)
 {
-	char pathbuf[MAXPATHLEN];
+	char pathbuf[PATH_MAX];
 	const char *path, *ptr;
 
 	path = name;
-- 
2.0.5
