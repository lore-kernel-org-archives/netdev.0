From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] ifb: dont hard code inet_net use
Date: Sun, 13 Jan 2013 09:46:34 -0800
Message-ID: <1358099194.8744.311.camel@edumazet-glaptop>
References: <50F1699E.1000200@hartkopp.net>
	 <20130112.132316.2121287993605534669.davem@davemloft.net>
	 <20130112.133630.257139657732337147.davem@davemloft.net>
	 <1358046374.20249.1789.camel@edumazet-glaptop>
	 <20130113035013.GJ5259@kvack.org>
	 <1358056199.20249.2121.camel@edumazet-glaptop>
	 <50F2C860.1060602@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Benjamin LaHaise <bcrl@kvack.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f44.google.com ([209.85.160.44]:37647 "EHLO
	mail-pb0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755647Ab3AMRqh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jan 2013 12:46:37 -0500
Received: by mail-pb0-f44.google.com with SMTP id uo1so1764206pbc.17
        for <netdev@vger.kernel.org>; Sun, 13 Jan 2013 09:46:37 -0800 (PST)
In-Reply-To: <50F2C860.1060602@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

ifb should lookup devices in the appropriate namespace.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: Benjamin LaHaise <bcrl@kvack.org>
---
 drivers/net/ifb.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ifb.c b/drivers/net/ifb.c
index 344dceb..8216438 100644
--- a/drivers/net/ifb.c
+++ b/drivers/net/ifb.c
@@ -90,7 +90,7 @@ static void ri_tasklet(unsigned long dev)
 		u64_stats_update_end(&dp->tsync);
 
 		rcu_read_lock();
-		skb->dev = dev_get_by_index_rcu(&init_net, skb->skb_iif);
+		skb->dev = dev_get_by_index_rcu(dev_net(_dev), skb->skb_iif);
 		if (!skb->dev) {
 			rcu_read_unlock();
 			dev_kfree_skb(skb);
