From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH] iproute2: off by one in nested attribute parse
Date: Mon, 10 Dec 2007 11:38:31 -0800
Message-ID: <20071210113831.7278f65b@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:60412 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754110AbXLJTjp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Dec 2007 14:39:45 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix off by one in nested attribute management.

Fixes segv in:
  tc qdisc show dev eth1
due to uninitialized attribute table.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
---
 lib/libnetlink.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/libnetlink.c b/lib/libnetlink.c
index 12883fe..d13596f 100644
--- a/lib/libnetlink.c
+++ b/lib/libnetlink.c
@@ -632,6 +632,6 @@ int __parse_rtattr_nested_compat(struct rtattr *tb[], int max, struct rtattr *rt
 		rta = RTA_DATA(rta) + RTA_ALIGN(len);
 		return parse_rtattr_nested(tb, max, rta);
 	}
-	memset(tb, 0, sizeof(struct rtattr *) * max);
+	memset(tb, 0, sizeof(struct rtattr *) * (max + 1));
 	return 0;
 }
-- 
1.5.3.4

