From: Masahide NAKAMURA <nakam@linux-ipv6.org>
Subject: [PATCH 1/3] [IPROUTE2] ip: xfrm: Clean-up for internal mask to filter.
Date: Fri, 24 Aug 2007 11:05:07 +0900
Message-ID: <11879211072343-git-send-email-nakam@linux-ipv6.org>
Cc: Masahide NAKAMURA <nakam@linux-ipv6.org>
To: Stephen Hemminger <shemminger@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from usagi025.linux-ipv6.org ([203.178.140.25]:44741 "EHLO
	triton.linux-ipv6.org" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1765775AbXHXC0w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2007 22:26:52 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove unused or redundant usage for xfrm_filter.

Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
---
 ip/xfrm_policy.c |   17 -----------------
 ip/xfrm_state.c  |    2 --
 2 files changed, 0 insertions(+), 19 deletions(-)

diff --git a/ip/xfrm_policy.c b/ip/xfrm_policy.c
index c1086f1..f4488ac 100644
--- a/ip/xfrm_policy.c
+++ b/ip/xfrm_policy.c
@@ -222,16 +222,10 @@ static int xfrm_policy_modify(int cmd, unsigned flags, int argc, char **argv)
 
 			NEXT_ARG();
 			xfrm_policy_dir_parse(&req.xpinfo.dir, &argc, &argv);
-
-			filter.dir_mask = XFRM_FILTER_MASK_FULL;
-
 		} else if (strcmp(*argv, "index") == 0) {
 			NEXT_ARG();
 			if (get_u32(&req.xpinfo.index, *argv, 0))
 				invarg("\"INDEX\" is invalid", *argv);
-
-			filter.index_mask = XFRM_FILTER_MASK_FULL;
-
 		} else if (strcmp(*argv, "ptype") == 0) {
 			if (ptypep)
 				duparg("ptype", *argv);
@@ -239,9 +233,6 @@ static int xfrm_policy_modify(int cmd, unsigned flags, int argc, char **argv)
 
 			NEXT_ARG();
 			xfrm_policy_ptype_parse(&upt.type, &argc, &argv);
-
-			filter.dir_mask = XFRM_FILTER_MASK_FULL;
-
 		} else if (strcmp(*argv, "action") == 0) {
 			NEXT_ARG();
 			if (strcmp(*argv, "allow") == 0)
@@ -250,16 +241,10 @@ static int xfrm_policy_modify(int cmd, unsigned flags, int argc, char **argv)
 				req.xpinfo.action = XFRM_POLICY_BLOCK;
 			else
 				invarg("\"action\" value is invalid\n", *argv);
-
-			filter.action_mask = XFRM_FILTER_MASK_FULL;
-
 		} else if (strcmp(*argv, "priority") == 0) {
 			NEXT_ARG();
 			if (get_u32(&req.xpinfo.priority, *argv, 0))
 				invarg("\"PRIORITY\" is invalid", *argv);
-
-			filter.priority_mask = XFRM_FILTER_MASK_FULL;
-
 		} else if (strcmp(*argv, "limit") == 0) {
 			NEXT_ARG();
 			xfrm_lifetime_cfg_parse(&req.xpinfo.lft, &argc, &argv);
@@ -888,8 +873,6 @@ static int xfrm_policy_flush(int argc, char **argv)
 
 			NEXT_ARG();
 			xfrm_policy_ptype_parse(&upt.type, &argc, &argv);
-
-			filter.dir_mask = XFRM_FILTER_MASK_FULL;
 		} else
 			invarg("unknown", *argv);
 
diff --git a/ip/xfrm_state.c b/ip/xfrm_state.c
index 54e1330..2b68f49 100644
--- a/ip/xfrm_state.c
+++ b/ip/xfrm_state.c
@@ -216,8 +216,6 @@ static int xfrm_state_flag_parse(__u8 *flags, int *argcp, char ***argvp)
 		}
 	}
 
-	filter.state_flags_mask = XFRM_FILTER_MASK_FULL;
-
 	*argcp = argc;
 	*argvp = argv;
 
-- 
1.4.4.2

