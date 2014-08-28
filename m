From: vadimk <vadim4j@gmail.com>
Subject: Added Sign-off [PATCH] ip netns: Show error message if mkdir failed to create /var/run/netns
Date: Thu, 28 Aug 2014 16:56:03 +0300
Message-ID: <1409234163-7567-1-git-send-email-vadim4j@gmail.com>
Cc: vadimk <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f51.google.com ([209.85.215.51]:53912 "EHLO
	mail-la0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750754AbaH1OD5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Aug 2014 10:03:57 -0400
Received: by mail-la0-f51.google.com with SMTP id gl10so966342lab.38
        for <netdev@vger.kernel.org>; Thu, 28 Aug 2014 07:03:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently if mkdir failed with "Permission denied" error then "mount --make-shared ..."
error message will be showed because /var/run/netns does not exist.

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 ip/ipnetns.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/ip/ipnetns.c b/ip/ipnetns.c
index 633b5b9..7f82908 100644
--- a/ip/ipnetns.c
+++ b/ip/ipnetns.c
@@ -407,7 +407,13 @@ static int netns_add(int argc, char **argv)
 	snprintf(netns_path, sizeof(netns_path), "%s/%s", NETNS_RUN_DIR, name);
 
 	/* Create the base netns directory if it doesn't exist */
-	mkdir(NETNS_RUN_DIR, S_IRWXU|S_IRGRP|S_IXGRP|S_IROTH|S_IXOTH);
+	if (mkdir(NETNS_RUN_DIR, S_IRWXU|S_IRGRP|S_IXGRP|S_IROTH|S_IXOTH)) {
+		if (errno != EEXIST) {
+			fprintf(stderr, "mkdir %s failed: %s\n",
+				NETNS_RUN_DIR, strerror(errno));
+			return -1;
+		}
+	}
 
 	/* Make it possible for network namespace mounts to propagate between
 	 * mount namespaces.  This makes it likely that a unmounting a network
-- 
2.0.4
