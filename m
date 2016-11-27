From: Roi Dayan <roid@mellanox.com>
Subject: [PATCH iproute2 1/2] devlink: Add usage help for eswitch subcommand
Date: Sun, 27 Nov 2016 13:21:02 +0200
Message-ID: <1480245663-814-2-git-send-email-roid@mellanox.com>
References: <1480245663-814-1-git-send-email-roid@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:35862 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753810AbcK0LVW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 27 Nov 2016 06:21:22 -0500
In-Reply-To: <1480245663-814-1-git-send-email-roid@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add missing usage help for devlink dev eswitch subcommand.

Signed-off-by: Roi Dayan <roid@mellanox.com>
Reviewed-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 devlink/devlink.c      |    7 ++++++-
 man/man8/devlink-dev.8 |    2 +-
 2 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/devlink/devlink.c b/devlink/devlink.c
index ccca0fb..673234f 100644
--- a/devlink/devlink.c
+++ b/devlink/devlink.c
@@ -963,6 +963,8 @@ static bool dl_dump_filter(struct dl *dl, struct nlattr **tb)
 static void cmd_dev_help(void)
 {
 	pr_err("Usage: devlink dev show [ DEV ]\n");
+	pr_err("       devlink dev eswitch set DEV [ mode { legacy | switchdev } ]\n");
+	pr_err("       devlink dev eswitch show DEV\n");
 }
 
 static bool cmp_arr_last_handle(struct dl *dl, const char *bus_name,
@@ -1259,7 +1261,10 @@ static int cmd_dev_eswitch_set(struct dl *dl)
 
 static int cmd_dev_eswitch(struct dl *dl)
 {
-	if (dl_argv_match(dl, "set")) {
+	if (dl_argv_match(dl, "help") || dl_no_arg(dl)) {
+		cmd_dev_help();
+		return 0;
+	} else if (dl_argv_match(dl, "set")) {
 		dl_arg_inc(dl);
 		return cmd_dev_eswitch_set(dl);
 	} else if (dl_argv_match(dl, "show")) {
diff --git a/man/man8/devlink-dev.8 b/man/man8/devlink-dev.8
index 9ce3193..931e334 100644
--- a/man/man8/devlink-dev.8
+++ b/man/man8/devlink-dev.8
@@ -54,7 +54,7 @@ BUS_NAME/BUS_ADDRESS
 
 .TP
 .BR mode " { " legacy " | " switchdev " } "
-set eswitch mode
+Set eswitch mode
 
 .I legacy
 - Legacy SRIOV
-- 
1.7.1
