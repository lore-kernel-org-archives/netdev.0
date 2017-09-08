From: Roman Mashak <mrv@mojatatu.com>
Subject: [PATCH iproute2 3/3] bridge: request vlans along with link information
Date: Fri,  8 Sep 2017 17:52:23 -0400
Message-ID: <1504907543-14394-4-git-send-email-mrv@mojatatu.com>
References: <1504907543-14394-1-git-send-email-mrv@mojatatu.com>
Cc: netdev@vger.kernel.org, jhs@mojatatu.com,
        Roman Mashak <mrv@mojatatu.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:36219 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932323AbdIHVxC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 8 Sep 2017 17:53:02 -0400
Received: by mail-it0-f68.google.com with SMTP id 3so1711916ity.3
        for <netdev@vger.kernel.org>; Fri, 08 Sep 2017 14:53:02 -0700 (PDT)
In-Reply-To: <1504907543-14394-1-git-send-email-mrv@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Roman Mashak <mrv@mojatatu.com>
---
 bridge/link.c | 16 +++++++++++++---
 1 file changed, 13 insertions(+), 3 deletions(-)

diff --git a/bridge/link.c b/bridge/link.c
index 60200f1..9e4206f 100644
--- a/bridge/link.c
+++ b/bridge/link.c
@@ -461,9 +461,19 @@ static int brlink_show(int argc, char **argv)
 		}
 	}
 
-	if (rtnl_wilddump_request(&rth, PF_BRIDGE, RTM_GETLINK) < 0) {
-		perror("Cannon send dump request");
-		exit(1);
+	if (show_details) {
+		if (rtnl_wilddump_req_filter(&rth, PF_BRIDGE, RTM_GETLINK,
+					     (compress_vlans ?
+					      RTEXT_FILTER_BRVLAN_COMPRESSED :
+					      RTEXT_FILTER_BRVLAN)) < 0) {
+			perror("Cannon send dump request");
+			exit(1);
+		}
+	} else {
+		if (rtnl_wilddump_request(&rth, PF_BRIDGE, RTM_GETLINK) < 0) {
+			perror("Cannon send dump request");
+			exit(1);
+		}
 	}
 
 	if (rtnl_dump_filter(&rth, print_linkinfo, stdout) < 0) {
-- 
1.9.1
