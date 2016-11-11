From: David Decotigny <ddecotig@gmail.com>
Subject: [PATCH iproute2 v1 1/2] iproute2: avoid exit in case of error.
Date: Fri, 11 Nov 2016 10:55:36 -0800
Message-ID: <1478890537-88715-1-git-send-email-ddecotig@gmail.com>
Cc: netdev@vger.kernel.org, David Decotigny <ddecotig@gmail.com>
To: Stephen Hemminger <stephen@networkplumber.org>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:35993 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934591AbcKKTJE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Nov 2016 14:09:04 -0500
Received: by mail-pg0-f66.google.com with SMTP id x23so2490957pgx.3
        for <netdev@vger.kernel.org>; Fri, 11 Nov 2016 11:09:03 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Be consistent with how non-0 print_route() return values are handled
elesewhere: return -1.


---
 ip/iproute.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ip/iproute.c b/ip/iproute.c
index 98bfad6..dae793b 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -1743,7 +1743,7 @@ static int iproute_get(int argc, char **argv)
 
 		if (print_route(NULL, &req.n, (void *)stdout) < 0) {
 			fprintf(stderr, "An error :-)\n");
-			exit(1);
+			return -1;
 		}
 
 		if (req.n.nlmsg_type != RTM_NEWROUTE) {
-- 
2.8.0.rc3.226.g39d4020
