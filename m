From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: vrf: remove skb_dst_force() after
 skb_dst_set()
Date: Thu, 21 Sep 2017 07:50:28 -0700
Message-ID: <1506005428.29839.129.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        David Ahern <dsa@cumulusnetworks.com>,
        Shrijeet Mukherjee <shm@cumulusnetworks.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:34108 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751892AbdIUOue (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 10:50:34 -0400
Received: by mail-pf0-f194.google.com with SMTP id g65so2586064pfe.1
        for <netdev@vger.kernel.org>; Thu, 21 Sep 2017 07:50:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

skb_dst_set(skb, dst) installs a normal (refcounted) dst, there is no
point using skb_dst_force(skb)

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/vrf.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index 9b243e6f3008bb5319844412cd49db1cd7bce594..cc18b7b11612d16271a1dbbb2d55c8f61781b9be 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -132,7 +132,6 @@ static int vrf_local_xmit(struct sk_buff *skb, struct net_device *dev,
 	skb_orphan(skb);
 
 	skb_dst_set(skb, dst);
-	skb_dst_force(skb);
 
 	/* set pkt_type to avoid skb hitting packet taps twice -
 	 * once on Tx and again in Rx processing
