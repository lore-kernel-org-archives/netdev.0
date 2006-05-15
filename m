From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] e1000: endian fixes
Date: Tue, 16 May 2006 02:54:32 +0400
Message-ID: <20060515225432.GG10143@mipter.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: cramerj@intel.com, netdev@vger.kernel.org,
	Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.191]:60429 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1750712AbWEOWzo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 May 2006 18:55:44 -0400
Received: by nf-out-0910.google.com with SMTP id g2so19084nfe
        for <netdev@vger.kernel.org>; Mon, 15 May 2006 15:55:42 -0700 (PDT)
To: Andrew Morton <akpm@osdl.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 drivers/net/e1000/e1000_main.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

--- 1/drivers/net/e1000/e1000_main.c
+++ 1/drivers/net/e1000/e1000_main.c
@@ -2451,7 +2451,7 @@ e1000_tso(struct e1000_adapter *adapter,
 
 		hdr_len = ((skb->h.raw - skb->data) + (skb->h.th->doff << 2));
 		mss = skb_shinfo(skb)->tso_size;
-		if (skb->protocol == ntohs(ETH_P_IP)) {
+		if (skb->protocol == htons(ETH_P_IP)) {
 			skb->nh.iph->tot_len = 0;
 			skb->nh.iph->check = 0;
 			skb->h.th->check =
@@ -2930,7 +2930,7 @@ e1000_xmit_frame(struct sk_buff *skb, st
 	/* Old method was to assume IPv4 packet by default if TSO was enabled.
 	 * 82571 hardware supports TSO capabilities for IPv6 as well...
 	 * no longer assume, we must. */
-	if (likely(skb->protocol == ntohs(ETH_P_IP)))
+	if (likely(skb->protocol == htons(ETH_P_IP)))
 		tx_flags |= E1000_TX_FLAGS_IPV4;
 
 	e1000_tx_queue(adapter, tx_ring, tx_flags,

