From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH iproute2] iplink: replace exit with return
Date: Sat,  9 Jan 2016 16:02:12 -0800
Message-ID: <1452384132-32261-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:34318 "EHLO
	mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756527AbcAJACQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Jan 2016 19:02:16 -0500
Received: by mail-pf0-f180.google.com with SMTP id q63so27377039pfb.1
        for <netdev@vger.kernel.org>; Sat, 09 Jan 2016 16:02:16 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This patch replaces exits with returns in iplink
command. Helps to continue on errors when
invoked with ip -force -batch.

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 ip/iplink.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/ip/iplink.c b/ip/iplink.c
index f30de86..c706d20 100644
--- a/ip/iplink.c
+++ b/ip/iplink.c
@@ -710,7 +710,7 @@ static int iplink_modify(int cmd, unsigned int flags, int argc, char **argv)
 			req.i.ifi_index = 0;
 			addattr32(&req.n, sizeof(req), IFLA_GROUP, group);
 			if (rtnl_talk(&rth, &req.n, NULL, 0) < 0)
-				exit(2);
+				return -2;
 			return 0;
 		}
 	}
@@ -809,7 +809,7 @@ static int iplink_modify(int cmd, unsigned int flags, int argc, char **argv)
 	}
 
 	if (rtnl_talk(&rth, &req.n, NULL, 0) < 0)
-		exit(2);
+		return -2;
 
 	return 0;
 }
-- 
1.9.1
