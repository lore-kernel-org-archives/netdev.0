From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 05/11] sfc: Stop changing header offsets on TX
Date: Thu, 12 Jul 2012 00:16:40 +0100
Message-ID: <1342048600.2613.64.camel@bwh-desktop.uk.solarflarecom.com>
References: <1342048389.2613.59.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:18993 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751010Ab2GKXQn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2012 19:16:43 -0400
In-Reply-To: <1342048389.2613.59.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is nothing in the VLAN driver or core VLAN support that
invalidates the TCP and IP header offsets.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/tx.c |    9 ---------
 1 files changed, 0 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/sfc/tx.c b/drivers/net/ethernet/sfc/tx.c
index cfa5f6d..9b225a7 100644
--- a/drivers/net/ethernet/sfc/tx.c
+++ b/drivers/net/ethernet/sfc/tx.c
@@ -651,17 +651,8 @@ static __be16 efx_tso_check_protocol(struct sk_buff *skb)
 	EFX_BUG_ON_PARANOID(((struct ethhdr *)skb->data)->h_proto !=
 			    protocol);
 	if (protocol == htons(ETH_P_8021Q)) {
-		/* Find the encapsulated protocol; reset network header
-		 * and transport header based on that. */
 		struct vlan_ethhdr *veh = (struct vlan_ethhdr *)skb->data;
 		protocol = veh->h_vlan_encapsulated_proto;
-		skb_set_network_header(skb, sizeof(*veh));
-		if (protocol == htons(ETH_P_IP))
-			skb_set_transport_header(skb, sizeof(*veh) +
-						 4 * ip_hdr(skb)->ihl);
-		else if (protocol == htons(ETH_P_IPV6))
-			skb_set_transport_header(skb, sizeof(*veh) +
-						 sizeof(struct ipv6hdr));
 	}
 
 	if (protocol == htons(ETH_P_IP)) {
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
