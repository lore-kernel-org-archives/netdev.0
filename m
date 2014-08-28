From: vadimk <vadim4j@gmail.com>
Subject: [PATCH] ip netns: Show error message if mkdir failed to create /var/run/netns
Date: Thu, 28 Aug 2014 15:38:28 +0300
Message-ID: <1409229508-4652-1-git-send-email-vadim4j@gmail.com>
Cc: vadimk <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f170.google.com ([209.85.217.170]:36434 "EHLO
	mail-lb0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750896AbaH1MqT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Aug 2014 08:46:19 -0400
Received: by mail-lb0-f170.google.com with SMTP id w7so831369lbi.29
        for <netdev@vger.kernel.org>; Thu, 28 Aug 2014 05:46:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently if mkdir failed with "Permission denied" error then "mount --make-shared ..."
error message will be showed because /var/run/netns does not exist.
---
 ip/ipnetns.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/ip/ipnetns.c b/ip/ipnetns.c
index 633b5b9..ee06eba 100644
--- a/ip/ipnetns.c
+++ b/ip/ipnetns.c
@@ -407,7 +407,11 @@ static int netns_add(int argc, char **argv)
 	snprintf(netns_path, sizeof(netns_path), "%s/%s", NETNS_RUN_DIR, name);
 
 	/* Create the base netns directory if it doesn't exist */
-	mkdir(NETNS_RUN_DIR, S_IRWXU|S_IRGRP|S_IXGRP|S_IROTH|S_IXOTH);
+	if (mkdir(NETNS_RUN_DIR, S_IRWXU|S_IRGRP|S_IXGRP|S_IROTH|S_IXOTH)) {
+		fprintf(stderr, "mkdir %s failed: %s\n",
+			NETNS_RUN_DIR, strerror(errno));
+		return -1;
+	}
 
 	/* Make it possible for network namespace mounts to propagate between
 	 * mount namespaces.  This makes it likely that a unmounting a network
-- 
2.0.4
