From: Abhishek Kulkarni <adkulkar@umail.iu.edu>
Subject: [9P PATCH 2/2] net/9p: Fix crash due to bad mount parameters.
Date: Wed,  1 Jul 2009 12:50:54 -0600
Message-ID: <1246474254-10401-2-git-send-email-adkulkar@umail.iu.edu>
References: <1246474254-10401-1-git-send-email-adkulkar@umail.iu.edu>
Cc: v9fs-developer@lists.sourceforge.net,
	Abhishek Kulkarni <adkulkar@umail.iu.edu>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f190.google.com ([209.85.216.190]:63209 "EHLO
	mail-px0-f190.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755549AbZGAStV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jul 2009 14:49:21 -0400
In-Reply-To: <1246474254-10401-1-git-send-email-adkulkar@umail.iu.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is not safe to use match_int without checking the token type returned
by match_token (especially when the token type returned is Opt_err and
args is empty). Fix it.

Signed-off-by: Abhishek Kulkarni <adkulkar@umail.iu.edu>
---
:100644 100644 c613ed08.. b884d98... M	net/9p/trans_fd.c
 net/9p/trans_fd.c |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/net/9p/trans_fd.c b/net/9p/trans_fd.c
index c613ed0..b884d98 100644
--- a/net/9p/trans_fd.c
+++ b/net/9p/trans_fd.c
@@ -731,12 +731,14 @@ static int parse_opts(char *params, struct p9_fd_opts *opts)
 		if (!*p)
 			continue;
 		token = match_token(p, tokens, args);
-		r = match_int(&args[0], &option);
-		if (r < 0) {
-			P9_DPRINTK(P9_DEBUG_ERROR,
-			 "integer field, but no integer?\n");
-			ret = r;
-			continue;
+		if (token != Opt_err) {
+			r = match_int(&args[0], &option);
+			if (r < 0) {
+				P9_DPRINTK(P9_DEBUG_ERROR,
+				"integer field, but no integer?\n");
+				ret = r;
+				continue;
+			}
 		}
 		switch (token) {
 		case Opt_port:
-- 
1.6.3.3

