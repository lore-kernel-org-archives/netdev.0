From: "Paul Moore" <paul.moore@hp.com>
Subject: [PATCH 2/2] NetLabel: correct CIPSO tag handling when adding new DOI definitions
Date: Fri, 05 Jan 2007 15:08:22 -0500
Message-ID: <20070105201639.625399003@hp.com>
References: <20070105200820.975960210@hp.com>
Cc: Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:60818 "EHLO atlrel6.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750729AbXAEURF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Jan 2007 15:17:05 -0500
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Content-Disposition: inline; filename=netlabel-cipso_add_fix
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The current netlbl_cipsov4_add_common() function has two problems which are
fixed with this patch.  The first is an off-by-one bug where it is possibile to
overflow the doi_def->tags[] array.  The second is a bug where the same 
doi_def->tags[] array was not always fully initialized, which caused sporadic
failures.

Signed-off-by: Paul Moore <paul.moore@hp.com>
---
 net/netlabel/netlabel_cipso_v4.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

Index: net-2.6.20_bugfix_3/net/netlabel/netlabel_cipso_v4.c
===================================================================
--- net-2.6.20_bugfix_3.orig/net/netlabel/netlabel_cipso_v4.c
+++ net-2.6.20_bugfix_3/net/netlabel/netlabel_cipso_v4.c
@@ -130,12 +130,12 @@ static int netlbl_cipsov4_add_common(str
 
 	nla_for_each_nested(nla, info->attrs[NLBL_CIPSOV4_A_TAGLST], nla_rem)
 		if (nla->nla_type == NLBL_CIPSOV4_A_TAG) {
-			if (iter > CIPSO_V4_TAG_MAXCNT)
+			if (iter >= CIPSO_V4_TAG_MAXCNT)
 				return -EINVAL;
 			doi_def->tags[iter++] = nla_get_u8(nla);
 		}
-	if (iter < CIPSO_V4_TAG_MAXCNT)
-		doi_def->tags[iter] = CIPSO_V4_TAG_INVALID;
+	while (iter < CIPSO_V4_TAG_MAXCNT)
+		doi_def->tags[iter++] = CIPSO_V4_TAG_INVALID;
 
 	return 0;
 }

--
paul moore
linux security @ hp
