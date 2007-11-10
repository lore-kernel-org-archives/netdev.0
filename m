From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH][IPV4] Remove bugus goto-s from ip_route_input_slow
Date: Sat, 10 Nov 2007 17:27:50 +0300
Message-ID: <4735BFE6.8010108@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:52598 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751151AbXKJO2A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 Nov 2007 09:28:00 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Both places look like

        if (err == XXX) 
               goto yyy;
   done:

while both yyy targets look like

        err = XXX;
        goto done;

so this is ok to remove the above if-s.

yyy labels are used in other places and are not removed.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 21b12de..c95b270 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1813,11 +1813,6 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 		goto martian_destination;
 
 	err = ip_mkroute_input(skb, &res, &fl, in_dev, daddr, saddr, tos);
-	if (err == -ENOBUFS)
-		goto e_nobufs;
-	if (err == -EINVAL)
-		goto e_inval;
-
 done:
 	in_dev_put(in_dev);
 	if (free_res)
-- 
1.5.3.4

