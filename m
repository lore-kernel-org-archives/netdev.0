From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH 2/4] ip: return correct exit code on route failure
Date: Wed,  6 May 2015 09:58:01 -0700
Message-ID: <1430931483-28595-3-git-send-email-stephen@networkplumber.org>
References: <1430931483-28595-1-git-send-email-stephen@networkplumber.org>
Cc: Stephen Hemminger <shemming@brocade.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:34863 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753119AbbEFQ6E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 12:58:04 -0400
Received: by pdbqd1 with SMTP id qd1so15048536pdb.2
        for <netdev@vger.kernel.org>; Wed, 06 May 2015 09:58:03 -0700 (PDT)
In-Reply-To: <1430931483-28595-1-git-send-email-stephen@networkplumber.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemming@brocade.com>

If kernel complains about ip route request, exit status should be
2 not 1.

This fixes regression introduced by:
commit 42ecedd4bae534fc688194a795eb4548c6530cda
Author: Roopa Prabhu <roopa@cumulusnetworks.com>
Date:   Tue Mar 17 19:26:32 2015 -0700

    fix ip -force -batch to continue on errors
---
 ip/iproute.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ip/iproute.c b/ip/iproute.c
index e0a6159..06aea6f 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -1164,7 +1164,7 @@ static int iproute_modify(int cmd, unsigned flags, int argc, char **argv)
 		req.r.rtm_family = AF_INET;
 
 	if (rtnl_talk(&rth, &req.n, 0, 0, NULL) < 0)
-		return -1;
+		return -2;
 
 	return 0;
 }
-- 
2.1.4
