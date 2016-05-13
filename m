From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next v2] vxlan: set mac_header correctly in GPE mode
Date: Fri, 13 May 2016 10:48:42 +0200
Message-ID: <2f5ecda4984940c2c6820cbbed18555d5023e2ed.1463129287.git.jbenc@redhat.com>
Cc: Simon Horman <simon.horman@netronome.com>,
	Shmulik Ladkani <shmulik.ladkani@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48973 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751675AbcEMIs5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 May 2016 04:48:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For VXLAN-GPE, the interface is ARPHRD_NONE, thus we need to reset
mac_header after pulling the outer header.

v2: Put the code to the existing conditional block as suggested by
    Shmulik Ladkani.

Fixes: e1e5314de08b ("vxlan: implement GPE")
Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 drivers/net/vxlan.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 2f29d20aa08f..25ab6bf013c4 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1381,6 +1381,7 @@ static int vxlan_rcv(struct sock *sk, struct sk_buff *skb)
 		if (!vxlan_set_mac(vxlan, vs, skb))
 			goto drop;
 	} else {
+		skb_reset_mac_header(skb);
 		skb->dev = vxlan->dev;
 		skb->pkt_type = PACKET_HOST;
 	}
-- 
1.8.3.1
