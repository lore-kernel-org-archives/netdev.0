From: Julian Anastasov <ja@ssi.bg>
Subject: [PATCH] ipv4: Fix again the time difference calculation
Date: Thu, 19 Jul 2012 23:02:45 +0300
Message-ID: <1342728165-2046-1-git-send-email-ja@ssi.bg>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:37053 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751036Ab2GST4t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jul 2012 15:56:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	Fix again the diff value in rt_bind_exception
after collision of two latest patches, my original commit
actually fixed the same problem.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/ipv4/route.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 89e39dc5..9f7ffbe 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1926,7 +1926,7 @@ restart:
 		if (daddr != fnhe_daddr)
 			continue;
 		if (pmtu) {
-			unsigned long diff = jiffies - expires;
+			unsigned long diff = expires - jiffies;
 
 			if (time_before(jiffies, expires)) {
 				rt->rt_pmtu = pmtu;
-- 
1.7.3.4
