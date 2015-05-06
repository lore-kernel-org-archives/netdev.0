From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH 3/4] ip: fix exit code for rule failures
Date: Wed,  6 May 2015 09:58:02 -0700
Message-ID: <1430931483-28595-4-git-send-email-stephen@networkplumber.org>
References: <1430931483-28595-1-git-send-email-stephen@networkplumber.org>
Cc: Stephen Hemminger <shemming@brocade.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:32905 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753143AbbEFQ6E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 12:58:04 -0400
Received: by pacwv17 with SMTP id wv17so14628601pac.0
        for <netdev@vger.kernel.org>; Wed, 06 May 2015 09:58:04 -0700 (PDT)
In-Reply-To: <1430931483-28595-1-git-send-email-stephen@networkplumber.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemming@brocade.com>

If ip rule command fails talking to kernel, exit code should be 2.
The sub-command is called by cmd loop and the exit code is negative
of return value from the command callback.
---
 ip/iprule.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ip/iprule.c b/ip/iprule.c
index 967969c..986a5bc 100644
--- a/ip/iprule.c
+++ b/ip/iprule.c
@@ -381,7 +381,7 @@ static int iprule_modify(int cmd, int argc, char **argv)
 		req.r.rtm_table = RT_TABLE_MAIN;
 
 	if (rtnl_talk(&rth, &req.n, 0, 0, NULL) < 0)
-		return 2;
+		return -2;
 
 	return 0;
 }
-- 
2.1.4
