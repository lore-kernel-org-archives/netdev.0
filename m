From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v2 5/6] ipaddress: drop unnecessary check in ipaddr_list_flush_or_save()
Date: Sun,  8 Nov 2015 21:22:20 +0100
Message-ID: <1447014141-3565-6-git-send-email-phil@nwl.cc>
References: <1447010471-559-1-git-send-email-phil@nwl.cc>
 <1447014141-3565-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:49079 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751499AbbKHUW0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Nov 2015 15:22:26 -0500
In-Reply-To: <1447014141-3565-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Right after ipaddr_reset_filter(), filter.family is always AF_UNSPEC.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 ip/ipaddress.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 23e0308..ff7f2a8 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -1446,10 +1446,7 @@ static int ipaddr_list_flush_or_save(int argc, char **argv, int action)
 
 	ipaddr_reset_filter(oneline, 0);
 	filter.showqueue = 1;
-
-	if (filter.family == AF_UNSPEC)
-		filter.family = preferred_family;
-
+	filter.family = preferred_family;
 	filter.group = -1;
 
 	if (action == IPADD_FLUSH) {
-- 
2.1.2
