From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 3/3] cls_bpf: further limit exec opcodes subset
Date: Wed, 23 Sep 2015 21:56:48 +0200
Message-ID: <30adbc348f5fcefddff51c8155086a87b389ccdb.1443037354.git.daniel@iogearbox.net>
References: <cover.1443037353.git.daniel@iogearbox.net>
Cc: ast@plumgrid.com, jhs@mojatatu.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:36067 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754582AbbIWT47 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 15:56:59 -0400
In-Reply-To: <cover.1443037353.git.daniel@iogearbox.net>
In-Reply-To: <cover.1443037353.git.daniel@iogearbox.net>
References: <cover.1443037353.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jamal suggested to further limit the currently allowed subset of opcodes
that may be used by a direct action return code as the intention is not
to replace the full action engine, but rather to have a minimal set that
can be used in the fast-path on things like ingress for some features
that cls_bpf supports.

Classifiers can, of course, still be chained together that have direct
action mode with those that have a full exec pass. For more complex
scenarios that go beyond this minimal set here, the full tcf_exts_exec()
path must be used.

Suggested-by: Jamal Hadi Salim <jhs@mojatatu.com>
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 net/sched/cls_bpf.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
index d6c0a0b..7eeffaf6 100644
--- a/net/sched/cls_bpf.c
+++ b/net/sched/cls_bpf.c
@@ -65,11 +65,8 @@ static int cls_bpf_exec_opcode(int code)
 {
 	switch (code) {
 	case TC_ACT_OK:
-	case TC_ACT_RECLASSIFY:
 	case TC_ACT_SHOT:
-	case TC_ACT_PIPE:
 	case TC_ACT_STOLEN:
-	case TC_ACT_QUEUED:
 	case TC_ACT_REDIRECT:
 	case TC_ACT_UNSPEC:
 		return code;
-- 
1.9.3
