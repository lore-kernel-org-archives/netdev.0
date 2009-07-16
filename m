From: Ben Greear <greearb@candelatech.com>
Subject: RFC:  VETH patch to zero timestamp.
Date: Thu, 16 Jul 2009 14:26:53 -0700
Message-ID: <4A5F9B1D.1050505@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: NetDev <netdev@vger.kernel.org>, xemul@openvz.org,
	"Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:33462 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933395AbZGPV1n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2009 17:27:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch below helps when using VETH and bridge(s)
This makes sure that the pkt timestamp is properly (re)calculated on
receiving the packet on the peer veth device.

I'm sure this patch is white-space damaged.  If this looks
useful, I'll generate a clean patch and send as attachment.

Signed-off-by:  Ben Greear<greearb@candelatech.com>


diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index 1097c72..e9136af 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -170,7 +173,12 @@ static int veth_xmit(struct sk_buff *skb, struct net_device *dev)

         if (skb->len > (rcv->mtu + MTU_PAD))
                 goto rx_drop;
-
+
+       /* Zero out the time-stamp so that receiving code is forced
+        * to recalculate it.
+        */
+       skb->tstamp.tv64 = 0;
+
         skb->pkt_type = PACKET_HOST;
         skb->protocol = eth_type_trans(skb, rcv);
         if (dev->features & NETIF_F_NO_CSUM)


Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

