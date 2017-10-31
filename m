From: Roman Mashak <mrv@mojatatu.com>
Subject: [PATCH iproute2 v2 1/1] ip netns: use strtol() instead of atoi()
Date: Tue, 31 Oct 2017 14:24:19 -0400
Message-ID: <1509474259-9988-1-git-send-email-mrv@mojatatu.com>
Cc: netdev@vger.kernel.org, jhs@mojatatu.com,
        Roman Mashak <mrv@mojatatu.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:57273 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932543AbdJaSY1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 14:24:27 -0400
Received: by mail-io0-f194.google.com with SMTP id m81so760319ioi.13
        for <netdev@vger.kernel.org>; Tue, 31 Oct 2017 11:24:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use strtol-based API to parse and validate integer input; atoi() does
not detect errors and may yield undefined behaviour if result can't be
represented.

v2: use get_unsigned() since network namespace is really an unsigned value.

Signed-off-by: Roman Mashak <mrv@mojatatu.com>
---
 ip/ipnetns.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/ip/ipnetns.c b/ip/ipnetns.c
index afb4978..bad7933 100644
--- a/ip/ipnetns.c
+++ b/ip/ipnetns.c
@@ -700,7 +700,8 @@ static int netns_set(int argc, char **argv)
 {
 	char netns_path[PATH_MAX];
 	const char *name;
-	int netns, nsid;
+	unsigned int nsid;
+	int netns;
 
 	if (argc < 1) {
 		fprintf(stderr, "No netns name specified\n");
@@ -711,7 +712,8 @@ static int netns_set(int argc, char **argv)
 		return -1;
 	}
 	name = argv[0];
-	nsid = atoi(argv[1]);
+	if (get_unsigned(&nsid, argv[1], 0))
+		invarg("Invalid \"netnsid\" value\n", argv[1]);
 
 	snprintf(netns_path, sizeof(netns_path), "%s/%s", NETNS_RUN_DIR, name);
 	netns = open(netns_path, O_RDONLY | O_CLOEXEC);
-- 
1.9.1
