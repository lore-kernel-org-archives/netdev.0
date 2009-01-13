From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [1/2] e1000e: Invoke VLAN GRO handler
Date: Tue, 13 Jan 2009 20:26:25 +1100
Message-ID: <20090113092625.GA28015@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:35826 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752263AbZAMJ0c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2009 04:26:32 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave:

I'm starting to convert the LRO users now.  Here's the first
patch which is trivial.  It simply completes the test driver
that I started out with.

e1000e: Invoke VLAN GRO handler

Now that VLAN has GRO support as well, we can call its GRO handler
as well.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 91817d0..f73faac 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -99,8 +99,8 @@ static void e1000_receive_skb(struct e1000_adapter *adapter,
 	skb->protocol = eth_type_trans(skb, netdev);
 
 	if (adapter->vlgrp && (status & E1000_RXD_STAT_VP))
-		vlan_hwaccel_receive_skb(skb, adapter->vlgrp,
-					 le16_to_cpu(vlan));
+		vlan_gro_receive(&adapter->napi, adapter->vlgrp,
+				 le16_to_cpu(vlan), skb);
 	else
 		napi_gro_receive(&adapter->napi, skb);
 }

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
