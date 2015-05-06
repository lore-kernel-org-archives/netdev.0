From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH 4/4] ip: fix exit code for addrlabel
Date: Wed,  6 May 2015 09:58:03 -0700
Message-ID: <1430931483-28595-5-git-send-email-stephen@networkplumber.org>
References: <1430931483-28595-1-git-send-email-stephen@networkplumber.org>
Cc: Stephen Hemminger <shemming@brocade.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:32777 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753164AbbEFQ6G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 12:58:06 -0400
Received: by pdbnk13 with SMTP id nk13so15132458pdb.0
        for <netdev@vger.kernel.org>; Wed, 06 May 2015 09:58:05 -0700 (PDT)
In-Reply-To: <1430931483-28595-1-git-send-email-stephen@networkplumber.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemming@brocade.com>

The exit code for ip label was not correct.
The return from the command function is negated and turned into
the exit code on failure.
---
 ip/ipaddrlabel.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/ip/ipaddrlabel.c b/ip/ipaddrlabel.c
index f6a638b..19a9308 100644
--- a/ip/ipaddrlabel.c
+++ b/ip/ipaddrlabel.c
@@ -183,7 +183,7 @@ static int ipaddrlabel_modify(int cmd, int argc, char **argv)
 		req.ifal.ifal_family = AF_INET6;
 
 	if (rtnl_talk(&rth, &req.n, 0, 0, NULL) < 0)
-		return 2;
+		return -2;
 
 	return 0;
 }
@@ -232,12 +232,12 @@ static int ipaddrlabel_flush(int argc, char **argv)
 
 	if (rtnl_wilddump_request(&rth, af, RTM_GETADDRLABEL) < 0) {
 		perror("Cannot send dump request");
-		return 1;
+		return -1;
 	}
 
 	if (rtnl_dump_filter(&rth, flush_addrlabel, NULL) < 0) {
 		fprintf(stderr, "Flush terminated\n");
-		return 1;
+		return -1;
 	}
 
 	return 0;
-- 
2.1.4
