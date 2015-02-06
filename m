From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH] ethtool: return non-zero from do_sset() when any of ETHTOOL_{G,S}* fails
Date: Fri,  6 Feb 2015 16:24:43 +0100
Message-ID: <1423236283-32446-1-git-send-email-ivecera@redhat.com>
Cc: Ben Hutchings <ben@decadent.org.uk>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43738 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755565AbbBFPYy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Feb 2015 10:24:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Function do_sset returns unconditionally zero error code without regard
to return value of ETHTOOL_{G,S}* ioctls.

Cc: Ben Hutchings <ben@decadent.org.uk>
Signed-off-by: Ivan Vecera <ivecera@redhat.com>
---
 ethtool.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index bf583f3..c004d41 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -2357,7 +2357,7 @@ static int do_sset(struct cmd_context *ctx)
 	int argc = ctx->argc;
 	char **argp = ctx->argp;
 	int i;
-	int err;
+	int err, result = 0;
 
 	for (i = 0; i < ARRAY_SIZE(flags_msglvl); i++)
 		flag_to_cmdline_info(flags_msglvl[i].name,
@@ -2617,6 +2617,7 @@ static int do_sset(struct cmd_context *ctx)
 				fprintf(stderr, "  not setting transceiver\n");
 			if (mdix_wanted != -1)
 				fprintf(stderr, "  not setting mdix\n");
+			result = err;
 		}
 	}
 
@@ -2650,6 +2651,7 @@ static int do_sset(struct cmd_context *ctx)
 				fprintf(stderr, "  not setting wol\n");
 			if (sopass_change)
 				fprintf(stderr, "  not setting sopass\n");
+			result = err;
 		}
 	}
 
@@ -2668,9 +2670,10 @@ static int do_sset(struct cmd_context *ctx)
 			if (err < 0)
 				perror("Cannot set new msglvl");
 		}
+		result = err;
 	}
 
-	return 0;
+	return result;
 }
 
 static int do_gregs(struct cmd_context *ctx)
-- 
2.0.5
