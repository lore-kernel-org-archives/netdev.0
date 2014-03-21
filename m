From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next 4/4] net: Don't clear skbuff hash for IP fragments
Date: Thu, 20 Mar 2014 17:09:23 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1403201702170.7148@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f201.google.com ([209.85.128.201]:42941 "EHLO
	mail-ve0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965867AbaCUAJY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2014 20:09:24 -0400
Received: by mail-ve0-f201.google.com with SMTP id cz12so202520veb.0
        for <netdev@vger.kernel.org>; Thu, 20 Mar 2014 17:09:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is nothing to gain by clearing hash, it shouldn't be an L4
hash anyway.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/ipv4/ip_fragment.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/ipv4/ip_fragment.c b/net/ipv4/ip_fragment.c
index c10a3ce..10a64de 100644
--- a/net/ipv4/ip_fragment.c
+++ b/net/ipv4/ip_fragment.c
@@ -704,7 +704,6 @@ struct sk_buff *ip_check_defrag(struct sk_buff *skb, u32 user)
 			memset(IPCB(skb), 0, sizeof(struct inet_skb_parm));
 			if (ip_defrag(skb, user))
 				return NULL;
-			skb_clear_hash(skb);
 		}
 	}
 	return skb;
-- 
1.9.1.423.g4596e3a
