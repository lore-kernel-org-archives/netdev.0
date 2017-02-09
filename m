From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH iproute] tc: matchall: Print skip flags when dumping a filter
Date: Thu,  9 Feb 2017 15:10:14 +0200
Message-ID: <1486645814-16906-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:43166 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752498AbdBINh0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 9 Feb 2017 08:37:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Print the skip flags when we dump a filter.

Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Acked by: Yotam Gigi <yotamg@mellanox.com>
---
 tc/f_matchall.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/tc/f_matchall.c b/tc/f_matchall.c
index 04e524e..ac48630 100644
--- a/tc/f_matchall.c
+++ b/tc/f_matchall.c
@@ -130,6 +130,15 @@ static int matchall_print_opt(struct filter_util *qu, FILE *f,
 			sprint_tc_classid(rta_getattr_u32(tb[TCA_MATCHALL_CLASSID]), b1));
 	}
 
+	if (tb[TCA_MATCHALL_FLAGS]) {
+		__u32 flags = rta_getattr_u32(tb[TCA_MATCHALL_FLAGS]);
+
+		if (flags & TCA_CLS_FLAGS_SKIP_HW)
+			fprintf(f, "\n  skip_hw");
+		if (flags & TCA_CLS_FLAGS_SKIP_SW)
+			fprintf(f, "\n  skip_sw");
+	}
+
 	if (tb[TCA_MATCHALL_ACT])
 		tc_print_action(f, tb[TCA_MATCHALL_ACT]);
 
-- 
2.3.7
