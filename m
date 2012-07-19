From: David Miller <davem@davemloft.net>
Subject: [PATCH] ipv4: Fix time difference calculation in
 rt_bind_exception().
Date: Thu, 19 Jul 2012 08:50:38 -0700 (PDT)
Message-ID: <20120719.085038.1115505959071907817.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45628 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750867Ab2GSPuj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2012 11:50:39 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	by shards.monkeyblade.net (Postfix) with ESMTPSA id CEC6D58447A
	for <netdev@vger.kernel.org>; Thu, 19 Jul 2012 08:50:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Reported-by: Steffen Klassert <steffen.klassert@secunet.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/route.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index f67e702..2c25581 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1907,7 +1907,7 @@ static void rt_bind_exception(struct rtable *rt, struct fib_nh *nh, __be32 daddr
 		if (fnhe->fnhe_daddr == daddr) {
 			if (fnhe->fnhe_pmtu) {
 				unsigned long expires = fnhe->fnhe_expires;
-				unsigned long diff = jiffies - expires;
+				unsigned long diff = expires - jiffies;
 
 				if (time_before(jiffies, expires)) {
 					rt->rt_pmtu = fnhe->fnhe_pmtu;
-- 
1.7.10.4
