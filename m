From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next 5/8] i40e: Set skb->csum_level for encapsulated
 checksum
Date: Mon, 25 Aug 2014 17:56:25 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1408251737001.5113@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f201.google.com ([209.85.220.201]:56362 "EHLO
	mail-vc0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757019AbaHZBDc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2014 21:03:32 -0400
Received: by mail-vc0-f201.google.com with SMTP id le20so1668557vcb.0
        for <netdev@vger.kernel.org>; Mon, 25 Aug 2014 18:03:32 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Set skb->csum_level instead of skb->encapsulation when indicating
CHECKSUM_UNNECESSARY for an encapsulated checksum.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index a51aa37..4dec093 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -1213,7 +1213,6 @@ static inline void i40e_rx_checksum(struct i40e_vsi *vsi,
 	ipv6_tunnel = (rx_ptype > I40E_RX_PTYPE_GRENAT6_MAC_PAY3) &&
 		      (rx_ptype < I40E_RX_PTYPE_GRENAT6_MACVLAN_IPV6_ICMP_PAY4);
 
-	skb->encapsulation = ipv4_tunnel || ipv6_tunnel;
 	skb->ip_summed = CHECKSUM_NONE;
 
 	/* Rx csum enabled and ip headers found? */
@@ -1287,6 +1286,7 @@ static inline void i40e_rx_checksum(struct i40e_vsi *vsi,
 	}
 
 	skb->ip_summed = CHECKSUM_UNNECESSARY;
+	skb->csum_level = ipv4_tunnel || ipv6_tunnel;
 
 	return;
 
-- 
2.1.0.rc2.206.gedb03e5
