From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] flow_keys: n_proto type should be __be16
Date: Wed, 04 Feb 2015 13:31:54 -0800
Message-ID: <1423085514.31870.20.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Govindarajulu Varadarajan <_govind@gmx.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:41532 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932213AbbBDVb4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Feb 2015 16:31:56 -0500
Received: by mail-ig0-f171.google.com with SMTP id h15so21652560igd.4
        for <netdev@vger.kernel.org>; Wed, 04 Feb 2015 13:31:56 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

(struct flow_keys)->n_proto is in network order, use
proper type for this.

Fixes following sparse errors :

net/core/flow_dissector.c:139:39: warning: incorrect type in assignment (different base types)
net/core/flow_dissector.c:139:39:    expected unsigned short [unsigned] [usertype] n_proto
net/core/flow_dissector.c:139:39:    got restricted __be16 [assigned] [usertype] proto
net/core/flow_dissector.c:237:23: warning: incorrect type in assignment (different base types)
net/core/flow_dissector.c:237:23:    expected unsigned short [unsigned] [usertype] n_proto
net/core/flow_dissector.c:237:23:    got restricted __be16 [assigned] [usertype] proto

Signed-off-by: Eric Dumazet <edumazet@google.com>
Fixes: e0f31d849867 ("flow_keys: Record IP layer protocol in skb_flow_dissect()")
---
 include/net/flow_keys.h |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/include/net/flow_keys.h b/include/net/flow_keys.h
index 7ee2df083542..dc8fd81412bf 100644
--- a/include/net/flow_keys.h
+++ b/include/net/flow_keys.h
@@ -22,9 +22,9 @@ struct flow_keys {
 		__be32 ports;
 		__be16 port16[2];
 	};
-	u16 thoff;
-	u16 n_proto;
-	u8 ip_proto;
+	u16	thoff;
+	__be16	n_proto;
+	u8	ip_proto;
 };
 
 bool __skb_flow_dissect(const struct sk_buff *skb, struct flow_keys *flow,
