From: Vadim Kochan <vadim4j@gmail.com>
Subject: [PATCH] ip monitor: Skip IPv6 ND user option messages
Date: Thu,  4 Sep 2014 23:24:22 +0300
Message-ID: <1409862262-4419-1-git-send-email-vadim4j@gmail.com>
Cc: Vadim Kochan <vadim4j@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:51765 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755311AbaIDUcV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Sep 2014 16:32:21 -0400
Received: by mail-wi0-f175.google.com with SMTP id ho1so1810084wib.2
        for <netdev@vger.kernel.org>; Thu, 04 Sep 2014 13:32:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IPv6 router sends ND messages with RDNSS option
which causes the printing of unknown message by 'ip monitor':

    Unknown message: 0000004c 00000044 00000000

Signed-off-by: Vadim Kochan <vadim4j@gmail.com>
---
 ip/ipmonitor.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/ip/ipmonitor.c b/ip/ipmonitor.c
index 70f2a7a..0029b52 100644
--- a/ip/ipmonitor.c
+++ b/ip/ipmonitor.c
@@ -131,7 +131,8 @@ static int accept_msg(const struct sockaddr_nl *who,
 	    n->nlmsg_type == RTM_NEWTCLASS ||
 	    n->nlmsg_type == RTM_DELTCLASS ||
 	    n->nlmsg_type == RTM_NEWTFILTER ||
-	    n->nlmsg_type == RTM_DELTFILTER)
+	    n->nlmsg_type == RTM_DELTFILTER ||
+	    n->nlmsg_type == RTM_NEWNDUSEROPT)
 		return 0;
 	if (n->nlmsg_type != NLMSG_ERROR && n->nlmsg_type != NLMSG_NOOP &&
 	    n->nlmsg_type != NLMSG_DONE) {
-- 
2.1.0
