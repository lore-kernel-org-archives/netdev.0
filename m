From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH net-2.6 1/7] atm: [br2684] Fix oops due to skb->dev being NULL
Date: Mon, 16 Jun 2008 13:26:51 -0400
Message-ID: <200806161726.m5GHQpV6003328@cmf.nrl.navy.mil>
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hedwig.cmf.nrl.navy.mil ([134.207.12.162]:45501 "EHLO
	hedwig.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752880AbYFPR1A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2008 13:27:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

please apply to net-2.6.

commit d1a3f097e4683798cc15c8306fa323bef40fe6a6
Author: Jorge Boncompte [DTI2] <jorge@dti2.net>
Date:   Sat Jun 14 16:46:14 2008 -0400

    atm: [br2684] Fix oops due to skb->dev being NULL
    
    It happens that if a packet arrives in a VC between the call to open it on
    the hardware and the call to change the backend to br2684, br2684_regvcc
    processes the packet and oopses dereferencing skb->dev because it is
    NULL before the call to br2684_push().
    
    Signed-off-by: Jorge Boncompte [DTI2] <jorge@dti2.net>
    Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>

diff --git a/net/atm/br2684.c b/net/atm/br2684.c
index 9d52ebf..ac60350 100644
--- a/net/atm/br2684.c
+++ b/net/atm/br2684.c
@@ -518,9 +518,9 @@ static int br2684_regvcc(struct atm_vcc *atmvcc, void __user * arg)
 		struct sk_buff *next = skb->next;
 
 		skb->next = skb->prev = NULL;
+		br2684_push(atmvcc, skb);
 		BRPRIV(skb->dev)->stats.rx_bytes -= skb->len;
 		BRPRIV(skb->dev)->stats.rx_packets--;
-		br2684_push(atmvcc, skb);
 
 		skb = next;
 	}
