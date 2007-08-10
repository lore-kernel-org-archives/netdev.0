From: akpm@linux-foundation.org
Subject: [patch 14/28] dccp: fix memory leak and clean up style - dccp_feat_empty_confirm()
Date: Fri, 10 Aug 2007 14:11:57 -0700
Message-ID: <200708102111.l7ALBwC1009414@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	jesper.juhl@gmail.com, ian.mcdonald@jandi.co.nz
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:33438 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S942237AbXHJVMJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 17:12:09 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jesper Juhl <jesper.juhl@gmail.com>

There's a memory leak in net/dccp/feat.c::dccp_feat_empty_confirm().  If we
hit the 'default:' case of the 'switch' statement, then we return without
freeing 'opt', thus leaking 'struct dccp_opt_pend' bytes.

The leak is fixed easily enough by adding a kfree(opt); before the return
statement.

The patch also changes the layout of the 'switch' to be more in line with
CodingStyle.

Signed-off-by: Jesper Juhl <jesper.juhl@gmail.com>
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 net/dccp/feat.c |   14 ++++++++++----
 1 files changed, 10 insertions(+), 4 deletions(-)

diff -puN net/dccp/feat.c~dccp-fix-memory-leak-and-clean-up-style-dccp_feat_empty_confirm net/dccp/feat.c
--- a/net/dccp/feat.c~dccp-fix-memory-leak-and-clean-up-style-dccp_feat_empty_confirm
+++ a/net/dccp/feat.c
@@ -327,10 +327,16 @@ static void dccp_feat_empty_confirm(stru
 	}
 
 	switch (type) {
-	case DCCPO_CHANGE_L: opt->dccpop_type = DCCPO_CONFIRM_R; break;
-	case DCCPO_CHANGE_R: opt->dccpop_type = DCCPO_CONFIRM_L; break;
-	default:	     DCCP_WARN("invalid type %d\n", type); return;
-
+	case DCCPO_CHANGE_L:
+		opt->dccpop_type = DCCPO_CONFIRM_R;
+		break;
+	case DCCPO_CHANGE_R:
+		opt->dccpop_type = DCCPO_CONFIRM_L;
+		break;
+	default:
+		DCCP_WARN("invalid type %d\n", type);
+		kfree(opt);
+		return;
 	}
 	opt->dccpop_feat = feature;
 	opt->dccpop_val	 = NULL;
_
