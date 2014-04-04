From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch iproute2] u32: add terminal parameter
Date: Fri,  4 Apr 2014 10:17:06 -0700
Message-ID: <1396631826-15188-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: davem@davemloft.net, Cong Wang <xiyou.wangcong@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:63476 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753809AbaDDRRz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Apr 2014 13:17:55 -0400
Received: by mail-pa0-f41.google.com with SMTP id fa1so3769627pad.28
        for <netdev@vger.kernel.org>; Fri, 04 Apr 2014 10:17:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It is useful to allow user to specify to terminate u32 filter matching
when there is no action. Currently we only terminate it when there is
an action attached.

Cc: Stephen Hemminger <stephen@networkplumber.org>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 tc/f_u32.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/tc/f_u32.c b/tc/f_u32.c
index f2a862d..a64ad10 100644
--- a/tc/f_u32.c
+++ b/tc/f_u32.c
@@ -1129,7 +1129,14 @@ static int u32_parse_opt(struct filter_util *qu, char *handle,
 			}
 			terminal_ok++;
 			continue;
-
+		} else if (matches(*argv, "terminal") == 0) {
+			argc--;
+			if (argc != 0) {
+				fprintf(stderr, "Illegal \"terminal\"\n");
+				return -1;
+			}
+			terminal_ok++;
+			continue;
 		} else if (matches(*argv, "police") == 0) {
 			NEXT_ARG();
 			if (parse_police(&argc, &argv, TCA_U32_POLICE, n)) {
-- 
1.7.11.7
