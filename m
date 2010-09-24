From: chavey@google.com
Subject: [PATCH 1/1] net-gre: clear skb->queue_mapping in GRE recv path
Date: Fri, 24 Sep 2010 16:18:52 -0700
Message-ID: <pvm39syraqr.fsf@chavey.mtv.corp.google.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.35]:44154 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758443Ab0IXXTB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Sep 2010 19:19:01 -0400
Received: from wpaz37.hot.corp.google.com (wpaz37.hot.corp.google.com [172.24.198.101])
	by smtp-out.google.com with ESMTP id o8ONIxcO032092
	for <netdev@vger.kernel.org>; Fri, 24 Sep 2010 16:19:00 -0700
Received: from pvg12 (pvg12.prod.google.com [10.241.210.140])
	by wpaz37.hot.corp.google.com with ESMTP id o8ONIwVS019891
	for <netdev@vger.kernel.org>; Fri, 24 Sep 2010 16:18:58 -0700
Received: by pvg12 with SMTP id 12so1063213pvg.36
        for <netdev@vger.kernel.org>; Fri, 24 Sep 2010 16:18:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: chavey <chavey@google.com>
Date: Fri, 24 Sep 2010 15:05:02 -0700

A continuous stream of errors:

  slbgre0 received packet on queue [123], but number of RX queues is 1
  net_ratelimit: 155786 callbacks suppressed

is filling up /var/log/messages.

This is due to not unsetting skb->queue_mapping in the GRE receive path.

Signed-off-by: chavey <chavey@google.com>
---
 net/ipv4/ip_gre.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 945b20a..53bdb97 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -641,6 +641,7 @@ static int ipgre_rcv(struct sk_buff *skb)
 		}
 
 		skb_tunnel_rx(skb, tunnel->dev);
+		skb_set_queue_mapping(skb, 0);
 
 		skb_reset_network_header(skb);
 		ipgre_ecn_decapsulate(iph, skb);
-- 
1.7.1

