From: Roman Mashak <mrv@mojatatu.com>
Subject: [PATCH iproute2 1/1] ip netns: use strtol() instead of atoi()
Date: Fri, 27 Oct 2017 12:55:27 -0400
Message-ID: <1509123327-31751-1-git-send-email-mrv@mojatatu.com>
Cc: netdev@vger.kernel.org, jhs@mojatatu.com,
        Roman Mashak <mrv@mojatatu.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:55932 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751770AbdJ0Qzf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 12:55:35 -0400
Received: by mail-io0-f196.google.com with SMTP id p186so14011652ioe.12
        for <netdev@vger.kernel.org>; Fri, 27 Oct 2017 09:55:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use strtol-based API to parse and validate integer input; atoi() does not detect
errors and may yield undefined behaviour if result can't be represented.

Signed-off-by: Roman Mashak <mrv@mojatatu.com>
---
 ip/ipnetns.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/ip/ipnetns.c b/ip/ipnetns.c
index afb4978..96da040 100644
--- a/ip/ipnetns.c
+++ b/ip/ipnetns.c
@@ -711,7 +711,8 @@ static int netns_set(int argc, char **argv)
 		return -1;
 	}
 	name = argv[0];
-	nsid = atoi(argv[1]);
+	if (get_integer(&nsid, argv[1], 0))
+		invarg("Invalid \"netnsid\" value\n", argv[1]);
 
 	snprintf(netns_path, sizeof(netns_path), "%s/%s", NETNS_RUN_DIR, name);
 	netns = open(netns_path, O_RDONLY | O_CLOEXEC);
-- 
1.9.1
