From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH iproute2] ip route: Add annotation for replaced routes
Date: Thu,  9 Jun 2016 13:05:42 -0700
Message-ID: <1465502742-17289-1-git-send-email-dsa@cumulusnetworks.com>
Cc: stephen@networkplumber.org, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:33273 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750752AbcFIUFt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2016 16:05:49 -0400
Received: by mail-pa0-f50.google.com with SMTP id ec8so16225296pac.0
        for <netdev@vger.kernel.org>; Thu, 09 Jun 2016 13:05:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If NLM_F_REPLACE flag is set then a route is replacing an existing route.
Prepend "Replaced " to these routes similar to how "Deleted " is added
to deleted routes.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 ip/iproute.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/ip/iproute.c b/ip/iproute.c
index 8224d7ffa94b..28b47bcb7312 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -363,6 +363,8 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 			return 0;
 	}
 
+	if (n->nlmsg_flags & NLM_F_REPLACE)
+		fprintf(fp, "Replaced ");
 	if (n->nlmsg_type == RTM_DELROUTE)
 		fprintf(fp, "Deleted ");
 	if ((r->rtm_type != RTN_UNICAST || show_details > 0) && !filter.type)
-- 
2.1.4
