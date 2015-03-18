From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH iproute2] tc: m_bpf: fix next arg selection after tc opcode
Date: Wed, 18 Mar 2015 10:13:34 +0100
Message-ID: <1af5314868a14e738b049319dc2c21102134bc9b.1426669396.git.daniel@iogearbox.net>
Cc: jhs@mojatatu.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:36089 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755538AbbCRJNi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Mar 2015 05:13:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Next argument after the tc opcode/verdict is optional, using NEXT_ARG()
requires to have another argument after that one otherwise tc will bail
out. Therefore, we need to advance to the next argument manually as done
elsewhere.

Fixes: 86ab59a6660f ("tc: add support for BPF based actions")
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 tc/m_bpf.c | 15 ++++++++++-----
 1 file changed, 10 insertions(+), 5 deletions(-)

diff --git a/tc/m_bpf.c b/tc/m_bpf.c
index 3b864f9..bc6cc47 100644
--- a/tc/m_bpf.c
+++ b/tc/m_bpf.c
@@ -89,20 +89,25 @@ static int parse_bpf(struct action_util *a, int *argc_p, char ***argv_p,
 	if (argc) {
 		if (matches(*argv, "reclassify") == 0) {
 			parm.action = TC_ACT_RECLASSIFY;
-			NEXT_ARG();
+			argc--;
+			argv++;
 		} else if (matches(*argv, "pipe") == 0) {
 			parm.action = TC_ACT_PIPE;
-			NEXT_ARG();
+			argc--;
+			argv++;
 		} else if (matches(*argv, "drop") == 0 ||
 			   matches(*argv, "shot") == 0) {
 			parm.action = TC_ACT_SHOT;
-			NEXT_ARG();
+			argc--;
+			argv++;
 		} else if (matches(*argv, "continue") == 0) {
 			parm.action = TC_ACT_UNSPEC;
-			NEXT_ARG();
+			argc--;
+			argv++;
 		} else if (matches(*argv, "pass") == 0) {
 			parm.action = TC_ACT_OK;
-			NEXT_ARG();
+			argc--;
+			argv++;
 		}
 	}
 
-- 
1.9.3
