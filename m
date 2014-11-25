From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next] gre: Set inner mac header in gro complete
Date: Tue, 25 Nov 2014 09:30:11 -0800
Message-ID: <1416936611-22702-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, linux@stwm.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:38860 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751218AbaKYRep (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 12:34:45 -0500
Received: by mail-ie0-f172.google.com with SMTP id tr6so1008248ieb.3
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2014 09:34:45 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Set the inner mac header to point to the GRE payload when
doing GRO. This is needed if we proceed to send the packet
through GRE GSO which now uses the inner mac header instead
of inner network header to determine the length of encapsulation
headers.

Reported-by: Wolfgang Walter <linux@stwm.de>
Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/ipv4/gre_offload.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/ipv4/gre_offload.c b/net/ipv4/gre_offload.c
index bb5947b..51973dd 100644
--- a/net/ipv4/gre_offload.c
+++ b/net/ipv4/gre_offload.c
@@ -247,6 +247,9 @@ static int gre_gro_complete(struct sk_buff *skb, int nhoff)
 		err = ptype->callbacks.gro_complete(skb, nhoff + grehlen);
 
 	rcu_read_unlock();
+
+	skb_set_inner_mac_header(skb, nhoff + grehlen);
+
 	return err;
 }
 
-- 
2.1.0.rc2.206.gedb03e5
