From: "Hubert Sokolowski" <h.sokolowski@wit.edu.pl>
Subject: [PATCH net-next RESEND] net: Do not call ndo_dflt_fdb_dump if
 ndo_fdb_dump is defined.
Date: Wed, 10 Dec 2014 19:37:01 -0000
Message-ID: <c6756bd161048ac4b4407e308045fe73.squirrel@poczta.wsisiz.edu.pl>
Mime-Version: 1.0
Content-Type: text/plain;charset=utf-8
Content-Transfer-Encoding: 8bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dervish.wsisiz.edu.pl ([213.135.44.54]:43912 "EHLO
	dervish.wsisiz.edu.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755357AbaLJThH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2014 14:37:07 -0500
Received: from localhost (localhost.localdomain [127.0.0.1])
	by dervish.wsisiz.edu.pl (Postfix) with ESMTP id 4701CC54054
	for <netdev@vger.kernel.org>; Wed, 10 Dec 2014 20:37:03 +0100 (CET)
Received: from dervish.wsisiz.edu.pl ([127.0.0.1])
	by localhost (dervish.wsisiz.edu.pl [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id LrsdRWEHxj18 for <netdev@vger.kernel.org>;
	Wed, 10 Dec 2014 20:37:01 +0100 (CET)
Received: from poczta.wsisiz.edu.pl (mask.wsisiz.edu.pl [IPv6:2001:1a68:a::35])
	by dervish.wsisiz.edu.pl (Postfix) with ESMTPSA id D4277C54062
	for <netdev@vger.kernel.org>; Wed, 10 Dec 2014 20:37:01 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change restores the semantic that was present
before 5e6d243587990a588143b9da3974833649595587
"bridge: netlink dump interface at par with brctl"
on how ndo_dflt_fdb_dump is called.
This semantic is still used for add and del operations
so let's keep it consistent.
Driver can still call ndo_dflt_fdb_dump from inside
its own fdb_dump routine when needed.

Signed-off-by: Hubert Sokolowski <h.sokolowski@wit.edu.pl>
---
 net/core/rtnetlink.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index eaa057f..a9e5c37 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -2692,10 +2692,11 @@ static int rtnl_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb)
 							 idx);
 		}

-		idx = ndo_dflt_fdb_dump(skb, cb, dev, NULL, idx);
 		if (dev->netdev_ops->ndo_fdb_dump)
 			idx = dev->netdev_ops->ndo_fdb_dump(skb, cb, bdev, dev,
 							    idx);
+		else
+			idx = ndo_dflt_fdb_dump(skb, cb, dev, NULL, idx);

 		cops = NULL;
 	}
-- 
1.9.3
