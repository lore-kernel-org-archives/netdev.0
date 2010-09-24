From: chavey@google.com
Subject: [PATCH 1/1] net-gre: clear skb->queue_mapping in GRE recv path
Date: Fri, 24 Sep 2010 16:15:48 -0700
Message-ID: <pvm4oderavv.fsf@chavey.mtv.corp.google.com>
Cc: netdev@vger.kernel.org, therbert@google.com
To: chavey@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:50774 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755424Ab0IXXPw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Sep 2010 19:15:52 -0400
Received: from kpbe17.cbf.corp.google.com (kpbe17.cbf.corp.google.com [172.25.105.81])
	by smtp-out.google.com with ESMTP id o8ONFp0V025645
	for <netdev@vger.kernel.org>; Fri, 24 Sep 2010 16:15:51 -0700
Received: from pwi9 (pwi9.prod.google.com [10.241.219.9])
	by kpbe17.cbf.corp.google.com with ESMTP id o8ONFoVA022493
	for <netdev@vger.kernel.org>; Fri, 24 Sep 2010 16:15:50 -0700
Received: by pwi9 with SMTP id 9so2877495pwi.2
        for <netdev@vger.kernel.org>; Fri, 24 Sep 2010 16:15:49 -0700 (PDT)
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

