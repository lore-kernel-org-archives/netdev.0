From: Hangbin Liu <liuhangbin@gmail.com>
Subject: [PATCH iproute2] devlink: Convert conditional in dl_argv_handle_port() to switch()
Date: Sun,  9 Oct 2016 10:14:18 +0800
Message-ID: <1475979258-29222-1-git-send-email-liuhangbin@gmail.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        Hangbin Liu <liuhangbin@gmail.com>, Phil Sutter <phil@nwl.cc>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:36717 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752591AbcJICQV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 8 Oct 2016 22:16:21 -0400
Received: by mail-pf0-f195.google.com with SMTP id 128so3500865pfz.3
        for <netdev@vger.kernel.org>; Sat, 08 Oct 2016 19:16:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Discovered by Phil's covscan. The final return statement is never reached.
This is not inherently clear from looking at the code, so change the
conditional to a switch() statement which should clarify this.

CC: Phil Sutter <phil@nwl.cc>
Signed-off-by: Hangbin Liu <liuhangbin@gmail.com>
---
 devlink/devlink.c | 17 ++++++++---------
 1 file changed, 8 insertions(+), 9 deletions(-)

diff --git a/devlink/devlink.c b/devlink/devlink.c
index e91dc50..ccca0fb 100644
--- a/devlink/devlink.c
+++ b/devlink/devlink.c
@@ -524,19 +524,18 @@ static int dl_argv_handle_port(struct dl *dl, char **p_bus_name,
 		return -EINVAL;
 	}
 	slash_count = strslashcount(str);
-	if (slash_count != 2 && slash_count != 0) {
+	switch (slash_count) {
+	case 0:
+		return __dl_argv_handle_port_ifname(dl, str, p_bus_name,
+						    p_dev_name, p_port_index);
+	case 2:
+		return __dl_argv_handle_port(str, p_bus_name,
+					     p_dev_name, p_port_index);
+	default:
 		pr_err("Wrong port identification string format.\n");
 		pr_err("Expected \"bus_name/dev_name/port_index\" or \"netdev_ifname\".\n");
 		return -EINVAL;
 	}
-	if (slash_count == 2) {
-		return __dl_argv_handle_port(str, p_bus_name,
-					     p_dev_name, p_port_index);
-	} else if (slash_count == 0) {
-		return __dl_argv_handle_port_ifname(dl, str, p_bus_name,
-						    p_dev_name, p_port_index);
-	}
-	return 0;
 }
 
 static int dl_argv_handle_both(struct dl *dl, char **p_bus_name,
-- 
2.5.5
