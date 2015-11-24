From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH v3 4/5] ipaddress: drop unnecessary check in ipaddr_list_flush_or_save()
Date: Tue, 24 Nov 2015 15:31:03 +0100
Message-ID: <1448375464-12145-5-git-send-email-phil@nwl.cc>
References: <20151123163115.5f8be482@xeon-e3>
 <1448375464-12145-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:58362 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753683AbbKXOb3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Nov 2015 09:31:29 -0500
In-Reply-To: <1448375464-12145-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Right after ipaddr_reset_filter(), filter.family is always AF_UNSPEC.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 ip/ipaddress.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 9811eb4..bc8359e 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -1451,10 +1451,7 @@ static int ipaddr_list_flush_or_save(int argc, char **argv, int action)
 
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
2.5.0
