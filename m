From: Casey Callendrello <casey.callendrello@coreos.com>
Subject: [PATCH iproute2] netns: make /var/run/netns bind-mount recursive
Date: Tue,  1 Aug 2017 17:46:09 +0200
Message-ID: <20170801154609.29895-1-casey.callendrello@coreos.com>
To: netdev@vger.kernel.org, stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:38746 "EHLO
        mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751599AbdHAPqM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Aug 2017 11:46:12 -0400
Received: by mail-wm0-f48.google.com with SMTP id m85so18634351wma.1
        for <netdev@vger.kernel.org>; Tue, 01 Aug 2017 08:46:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When ip netns {add|delete} is first run, it bind-mounts /var/run/netns
on top of itself, then marks it as shared. However, if there are already
bind-mounts in the directory from other tools, these would not be
propagated. Fix this by recursively bind-mounting.

Signed-off-by: Casey Callendrello <casey.callendrello@coreos.com>
---
 ip/ipnetns.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ip/ipnetns.c b/ip/ipnetns.c
index 198e9de8..9ee1fe6a 100644
--- a/ip/ipnetns.c
+++ b/ip/ipnetns.c
@@ -636,7 +636,7 @@ static int netns_add(int argc, char **argv)
 		}
 
 		/* Upgrade NETNS_RUN_DIR to a mount point */
-		if (mount(NETNS_RUN_DIR, NETNS_RUN_DIR, "none", MS_BIND, NULL)) {
+		if (mount(NETNS_RUN_DIR, NETNS_RUN_DIR, "none", MS_BIND | MS_REC, NULL)) {
 			fprintf(stderr, "mount --bind %s %s failed: %s\n",
 				NETNS_RUN_DIR, NETNS_RUN_DIR, strerror(errno));
 			return -1;
-- 
2.13.3
