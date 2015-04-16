From: Sridhar Samudrala <sridhar.samudrala@intel.com>
Subject: [PATCH] ethtool: return 1 as exit code on a settings(-s) failure.
Date: Thu, 16 Apr 2015 13:55:09 -0700
Message-ID: <1429217709-21625-1-git-send-email-sridhar.samudrala@intel.com>
To: bwh@kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:12563 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753582AbbDPUxv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Apr 2015 16:53:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently 0 is returned on both success or failure.

Signed-off-by: Sridhar Samudrala <sridhar.samudrala@intel.com>
---
 ethtool.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index 01b13a6..163dff2 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -2352,7 +2352,7 @@ static int do_sset(struct cmd_context *ctx)
 	int argc = ctx->argc;
 	char **argp = ctx->argp;
 	int i;
-	int err;
+	int err = 0;
 
 	for (i = 0; i < ARRAY_SIZE(flags_msglvl); i++)
 		flag_to_cmdline_info(flags_msglvl[i].name,
@@ -2665,7 +2665,7 @@ static int do_sset(struct cmd_context *ctx)
 		}
 	}
 
-	return 0;
+	return err ? 1 : 0;
 }
 
 static int do_gregs(struct cmd_context *ctx)
-- 
1.8.4.2
