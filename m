From: greearb@candelatech.com
Subject: [PATCH v2] ethtool:  Do not return error code if no changes were attempted.
Date: Thu, 19 Oct 2017 14:01:19 -0700
Message-ID: <1508446879-17056-1-git-send-email-greearb@candelatech.com>
Cc: linville@tuxdriver.com, Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:40846 "EHLO
        mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752036AbdJSVBZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 17:01:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

This makes it easier to properly handle errors when calling this
from scripts, etc.

Old behaviour:

$ ethtool -L eth3 combined 1
combined unmodified, ignoring
no channel parameters changed, aborting
current values: tx 0 rx 0 other 1 combined 1
[root@lf0313-6477 ethtool]# echo $?
1

New behaviour:

$ ./ethtool -L eth3 combined 1
combined unmodified, ignoring
no channel parameters changed.
current values: tx 0 rx 0 other 1 combined 1
[root@lf0313-6477 ethtool]# echo $?
0

Signed-off-by: Ben Greear <greearb@candelatech.com>
---

v2:  Fix comments, the # ./ethtool .... was removed by git of course.

 ethtool.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index ad18704..224efdb 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -1994,12 +1994,12 @@ static int do_schannels(struct cmd_context *ctx)
 			&changed);
 
 	if (!changed) {
-		fprintf(stderr, "no channel parameters changed, aborting\n");
+		fprintf(stderr, "no channel parameters changed.\n");
 		fprintf(stderr, "current values: tx %u rx %u other %u"
 			" combined %u\n", echannels.rx_count,
 			echannels.tx_count, echannels.other_count,
 			echannels.combined_count);
-		return 1;
+		return 0;
 	}
 
 	echannels.cmd = ETHTOOL_SCHANNELS;
-- 
2.7.5
