From: "Jorge Boncompte [DTI2]" <jorge@dti2.net>
Subject: [PATCH][ATM] br2684: Fix oops due to skb->dev being NULL
Date: Thu, 05 Jun 2008 17:43:50 +0200
Message-ID: <484809B6.2080904@dti2.net>
Reply-To: jorge@dti2.net
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: chas williams <chas@cmf.nrl.navy.mil>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from alcalazamora.dti2.net ([81.24.162.8]:1520 "EHLO
	alcalazamora.dti2.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753477AbYFEPvQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2008 11:51:16 -0400
Received: from [172.16.16.6] ([81.24.161.20])
	(authenticated user jorge@dti2.net)
	by alcalazamora.dti2.net (alcalazamora.dti2.net [81.24.162.8])
	(MDaemon PRO v9.6.5)
	with ESMTP id md50013607270.msg
	for <netdev@vger.kernel.org>; Thu, 05 Jun 2008 17:43:56 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	It happens that if a packet arrives in a VC between the call to open it 
on the hardware and the call to change the backend to br2684, 
br2684_regvcc processes the packet and oopses dereferencing skb->dev 
because it is NULL before the call to br2684_push().

Signed-off-by: Jorge Boncompte [DTI2] <jorge@dti2.net>
---
  net/atm/br2684.c |    2 +-
  1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/atm/br2684.c b/net/atm/br2684.c
index 9d52ebf..ac60350 100644
--- a/net/atm/br2684.c
+++ b/net/atm/br2684.c
@@ -518,9 +518,9 @@ static int br2684_regvcc(struct atm_vcc *atmvcc, 
void __user * arg)
  		struct sk_buff *next = skb->next;

  		skb->next = skb->prev = NULL;
+		br2684_push(atmvcc, skb);
  		BRPRIV(skb->dev)->stats.rx_bytes -= skb->len;
  		BRPRIV(skb->dev)->stats.rx_packets--;
-		br2684_push(atmvcc, skb);

  		skb = next;
  	}
-- 


