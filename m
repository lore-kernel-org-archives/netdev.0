From: Ben Greear <greearb@candelatech.com>
Subject: [PATCH] net/core:  Allow tagged VLAN packets to flow through VETH devices.
Date: Fri, 15 Oct 2010 11:35:05 -0700
Message-ID: <1287167705-28583-1-git-send-email-greearb@candelatech.com>
Cc: Ben Greear <greearb@candelatech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:52443 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932153Ab0JOSfI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Oct 2010 14:35:08 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When there are VLANs on a VETH device, the packets being transmitted
through the VETH device may be 4 bytes bigger than MTU.  A check
in dev_forward_skb did not take this into account and so dropped
these packets.

This patch is needed at least as far back as 2.6.34.7 and should
be considered for -stable.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 7f52603... 9fa308b... M	net/core/dev.c
 net/core/dev.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 7f52603..9fa308b 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1485,7 +1485,7 @@ int dev_forward_skb(struct net_device *dev, struct sk_buff *skb)
 	nf_reset(skb);
 
 	if (!(dev->flags & IFF_UP) ||
-	    (skb->len > (dev->mtu + dev->hard_header_len))) {
+	    (skb->len > (dev->mtu + dev->hard_header_len + VLAN_HLEN))) {
 		kfree_skb(skb);
 		return NET_RX_DROP;
 	}
-- 
1.6.2.5

