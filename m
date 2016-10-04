From: Igor Ryzhov <iryzhov@nfware.com>
Subject: [PATCH iproute2] fix netlink message length checks
Date: Tue,  4 Oct 2016 13:16:55 +0300
Message-ID: <1475576215-9829-1-git-send-email-iryzhov@nfware.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f65.google.com ([209.85.215.65]:35421 "EHLO
        mail-lf0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752605AbcJDKRJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Oct 2016 06:17:09 -0400
Received: by mail-lf0-f65.google.com with SMTP id s64so10074041lfs.2
        for <netdev@vger.kernel.org>; Tue, 04 Oct 2016 03:17:03 -0700 (PDT)
Received: from localhost.localdomain (vpn.arccn.ru. [95.182.74.2])
        by smtp.gmail.com with ESMTPSA id 24sm558358lfr.49.2016.10.04.03.17.01
        for <netdev@vger.kernel.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 04 Oct 2016 03:17:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Igor Ryzhov <iryzhov@nfware.com>
---
 ip/ipaddress.c | 2 +-
 lib/ll_map.c   | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index fcc3c53..3614837 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -1218,7 +1218,7 @@ static int print_selected_addrinfo(struct ifinfomsg *ifi,
 		if (n->nlmsg_type != RTM_NEWADDR)
 			continue;
 
-		if (n->nlmsg_len < NLMSG_LENGTH(sizeof(ifa)))
+		if (n->nlmsg_len < NLMSG_LENGTH(sizeof(*ifa)))
 			return -1;
 
 		if (ifa->ifa_index != ifi->ifi_index ||
diff --git a/lib/ll_map.c b/lib/ll_map.c
index 571d11e..4e4556c 100644
--- a/lib/ll_map.c
+++ b/lib/ll_map.c
@@ -90,7 +90,7 @@ int ll_remember_index(const struct sockaddr_nl *who,
 	if (n->nlmsg_type != RTM_NEWLINK && n->nlmsg_type != RTM_DELLINK)
 		return 0;
 
-	if (n->nlmsg_len < NLMSG_LENGTH(sizeof(ifi)))
+	if (n->nlmsg_len < NLMSG_LENGTH(sizeof(*ifi)))
 		return -1;
 
 	im = ll_get_by_index(ifi->ifi_index);
-- 
2.6.4
