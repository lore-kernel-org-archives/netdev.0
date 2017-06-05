From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch iproute2/net-next] tc: gact: fix control action parsing
Date: Mon,  5 Jun 2017 16:22:03 +0200
Message-ID: <20170605142203.4535-1-jiri@resnulli.us>
Cc: stephen@networkplumber.org, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:34192 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751112AbdFEOWG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2017 10:22:06 -0400
Received: by mail-wr0-f195.google.com with SMTP id u101so5131975wrc.1
        for <netdev@vger.kernel.org>; Mon, 05 Jun 2017 07:22:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

parse_action_control helper does advancing of the arg inside. So don't
do it outside.

Fixes: e67aba559581 ("tc: actions: add helpers to parse and print control actions")
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 tc/m_gact.c | 9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

diff --git a/tc/m_gact.c b/tc/m_gact.c
index d95aa11..1a25833 100644
--- a/tc/m_gact.c
+++ b/tc/m_gact.c
@@ -90,17 +90,14 @@ parse_gact(struct action_util *a, int *argc_p, char ***argv_p,
 
 	if (matches(*argv, "gact") == 0) {
 		ok++;
+		argc--;
+		argv++;
 	} else {
 		if (parse_action_control(&argc, &argv, &p.action, false) == -1)
 			usage();
 		ok++;
 	}
 
-	if (ok) {
-		argc--;
-		argv++;
-	}
-
 #ifdef CONFIG_GACT_PROB
 	if (ok && argc > 0) {
 		if (matches(*argv, "random") == 0) {
@@ -120,8 +117,6 @@ parse_gact(struct action_util *a, int *argc_p, char ***argv_p,
 			if (parse_action_control(&argc, &argv,
 						 &pp.paction, false) == -1)
 				usage();
-			argc--;
-			argv++;
 			if (get_u16(&pp.pval, *argv, 10)) {
 				fprintf(stderr, "Illegal probability val 0x%x\n", pp.pval);
 				return -1;
-- 
2.9.3
