From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH] tc: Fix for missing estimator initialization
Date: Wed,  3 Aug 2016 11:43:45 +0200
Message-ID: <1470217425-19709-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:37807 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752679AbcHCJxc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Aug 2016 05:53:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When switching to C99 initializers, I forgot to add this one. This means
that when trying to set an estimator value, tc would complain about
spurious duplicate estimator parameter. But much worse, the random
variable content is sent to the kernel regardless of whether an
estimator was given or not.

Fixes: d17b136f7d7dd ("Use C99 style initializers everywhere")
Reported-by: Stas Nichiporovich <stasn77@gmail.com>
Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 tc/tc_qdisc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tc/tc_qdisc.c b/tc/tc_qdisc.c
index bc87aab110e48..93c9a4c1daa28 100644
--- a/tc/tc_qdisc.c
+++ b/tc/tc_qdisc.c
@@ -45,7 +45,7 @@ static int usage(void)
 static int tc_qdisc_modify(int cmd, unsigned int flags, int argc, char **argv)
 {
 	struct qdisc_util *q = NULL;
-	struct tc_estimator est;
+	struct tc_estimator est = {};
 	struct {
 		struct tc_sizespec	szopts;
 		__u16			*data;
-- 
2.8.2
