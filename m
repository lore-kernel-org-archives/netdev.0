From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] macvlan: fix macvlan_get_size()
Date: Thu, 17 Jan 2013 13:30:49 -0800
Message-ID: <1358458249.11051.6.camel@edumazet-glaptop>
References: <50F60404.3090605@candelatech.com>
	 <1358316108.19956.82.camel@edumazet-glaptop>
	 <20130116.011120.2166745757980086775.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, netdev@vger.kernel.org,
	John Fastabend <john.r.fastabend@intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f43.google.com ([209.85.160.43]:60147 "EHLO
	mail-pb0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754663Ab3AQVaw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2013 16:30:52 -0500
Received: by mail-pb0-f43.google.com with SMTP id jt11so262204pbb.2
        for <netdev@vger.kernel.org>; Thu, 17 Jan 2013 13:30:52 -0800 (PST)
In-Reply-To: <20130116.011120.2166745757980086775.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

commit df8ef8f3aaa (macvlan: add FDB bridge ops and macvlan flags)
forgot to update macvlan_get_size() after the addition of
IFLA_MACVLAN_FLAGS

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: John Fastabend <john.r.fastabend@intel.com>
---
 drivers/net/macvlan.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 1047e58..7b44ebd 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -828,7 +828,10 @@ static int macvlan_changelink(struct net_device *dev,
 
 static size_t macvlan_get_size(const struct net_device *dev)
 {
-	return nla_total_size(4);
+	return (0
+		+ nla_total_size(4) /* IFLA_MACVLAN_MODE */
+		+ nla_total_size(2) /* IFLA_MACVLAN_FLAGS */
+		);
 }
 
 static int macvlan_fill_info(struct sk_buff *skb,
