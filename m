From: Ben Greear <greearb@candelatech.com>
Subject: PATCH:  veth:  Zero timestamp in xmit path.
Date: Tue, 21 Jul 2009 12:46:55 -0700
Message-ID: <4A661B2F.7000608@candelatech.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000901010506040908010605"
To: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:34124 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754035AbZGUTqz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2009 15:46:55 -0400
Received: from [192.168.100.195] (firewall.candelatech.com [70.89.124.249])
	(authenticated bits=0)
	by ns3.lanforge.com (8.14.2/8.14.2) with ESMTP id n6LJktw1028367
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 21 Jul 2009 12:46:55 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------000901010506040908010605
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch zero's the timestamp before handing the packet to
the peer interface.  This lets the peer recalculate the rx timestamp
if it cares about timestamps.

The patch is against net-next, compile tested there.  Similar patch was
functionally tested against 2.6.31-rc3.


Signed-Off-By:  Ben Greear<greearb@candelatech.com>

diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index f1d753d..190f784 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -171,6 +171,7 @@ static int veth_xmit(struct sk_buff *skb, struct net_device *dev)
  	if (skb->len > (rcv->mtu + MTU_PAD))
  		goto rx_drop;

+        skb->tstamp.tv64 = 0;
  	skb->pkt_type = PACKET_HOST;
  	skb->protocol = eth_type_trans(skb, rcv);
  	if (dev->features & NETIF_F_NO_CSUM)

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com


--------------000901010506040908010605
Content-Type: text/plain;
 name="veth_ts.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="veth_ts.patch"

diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index f1d753d..190f784 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -171,6 +171,7 @@ static int veth_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (skb->len > (rcv->mtu + MTU_PAD))
 		goto rx_drop;
 
+        skb->tstamp.tv64 = 0;
 	skb->pkt_type = PACKET_HOST;
 	skb->protocol = eth_type_trans(skb, rcv);
 	if (dev->features & NETIF_F_NO_CSUM)

--------------000901010506040908010605--
