From: Davide Caratti <dcaratti@redhat.com>
Subject: [iproute PATCH] tc: don't accept qdisc 'handle' greater than ffff
Date: Fri, 16 Sep 2016 10:30:00 +0200
Message-ID: <bdc0d8e58be9344b44fcd64a56b5b62004c108a1.1473930575.git.dcaratti@redhat.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        Phil Sutter <phil@nwl.cc>, Hangbin Liu <liuhangbin@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37570 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752001AbcIPIaT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 16 Sep 2016 04:30:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

since get_qdisc_handle() truncates the input value to 16 bit, return an
error and prompt "invalid qdisc ID" in case input 'handle' parameter needs
more than 16 bit to be stored.

Signed-off-by: Davide Caratti <dcaratti@redhat.com>
---
 tc/tc_util.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tc/tc_util.c b/tc/tc_util.c
index 15e49b7..24ca1f1 100644
--- a/tc/tc_util.c
+++ b/tc/tc_util.c
@@ -82,7 +82,7 @@ int get_qdisc_handle(__u32 *h, const char *str)
 	if (strcmp(str, "none") == 0)
 		goto ok;
 	maj = strtoul(str, &p, 16);
-	if (p == str)
+	if (p == str || maj >= (1 << 16))
 		return -1;
 	maj <<= 16;
 	if (*p != ':' && *p != 0)
-- 
2.5.5
