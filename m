From: Tom Herbert <therbert@google.com>
Subject: [PATCH v2 net-next 6/9] i40e: Set skb->csum_level for encapsulated
 checksum
Date: Wed, 27 Aug 2014 21:27:32 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1408272110160.32435@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f74.google.com ([209.85.192.74]:32890 "EHLO
	mail-qg0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965685AbaH1LSX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Aug 2014 07:18:23 -0400
Received: by mail-qg0-f74.google.com with SMTP id a108so176515qge.1
        for <netdev@vger.kernel.org>; Thu, 28 Aug 2014 04:18:22 -0700 (PDT)
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
