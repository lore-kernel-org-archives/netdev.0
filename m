From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH iproute2] ip route get: change exit to return to support batch commands
Date: Thu, 15 Oct 2015 15:23:50 -0700
Message-ID: <1444947830-19858-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:33847 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751401AbbJOWXz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2015 18:23:55 -0400
Received: by payp3 with SMTP id p3so51744210pay.1
        for <netdev@vger.kernel.org>; Thu, 15 Oct 2015 15:23:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

replace exit with return -2 on rtnl_talk failure

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
---
 ip/iproute.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ip/iproute.c b/ip/iproute.c
index da25548..b137f55 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -1643,7 +1643,7 @@ static int iproute_get(int argc, char **argv)
 		req.r.rtm_family = AF_INET;
 
 	if (rtnl_talk(&rth, &req.n, &req.n, sizeof(req)) < 0)
-		exit(2);
+		return -2;
 
 	if (connected && !from_ok) {
 		struct rtmsg *r = NLMSG_DATA(&req.n);
-- 
1.9.1
