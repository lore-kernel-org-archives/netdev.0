From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH] ip-address: constify match_link_kind arg
Date: Thu, 30 Jun 2016 16:47:02 +0200
Message-ID: <1467298022-7627-1-git-send-email-phil@nwl.cc>
References: <20160629171141.62b44c1f@xeon-e3>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:55779 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932094AbcF3OrQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Jun 2016 10:47:16 -0400
In-Reply-To: <20160629171141.62b44c1f@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since the function won't ever change the data 'kind' is pointing at, it
can sanely be made const.

Fixes: e0513807f6dbb ("ip-address: Support filtering by slave type, too")
Suggested-by: Stephen Hemminger <shemming@brocade.com>
Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 ip/ipaddress.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index d4d649505e15a..02bc9029d6b20 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -220,7 +220,7 @@ static char *parse_link_kind(struct rtattr *tb, bool slave)
 	return "";
 }
 
-static int match_link_kind(struct rtattr **tb, char *kind, bool slave)
+static int match_link_kind(struct rtattr **tb, const char *kind, bool slave)
 {
 	if (!tb[IFLA_LINKINFO])
 		return -1;
-- 
2.8.2
