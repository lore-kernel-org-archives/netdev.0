From: David Miller <davem@davemloft.net>
Subject: [PATCH 22/42] isdn: ipacx: Fix set-but-unused variables.
Date: Sun, 17 Apr 2011 17:33:39 -0700 (PDT)
Message-ID: <20110417.173339.242128093.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51051
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753985Ab1DRAeO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Apr 2011 20:34:14 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 9910C24C087
	for <netdev@vger.kernel.org>; Sun, 17 Apr 2011 17:33:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The variable 'cda2_cr' is set but unused in ctrl_complete().  Just
kill it off.

Keep the cs->readisac() call just in case the register read has side
effects.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/isdn/hisax/ipacx.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/isdn/hisax/ipacx.c b/drivers/isdn/hisax/ipacx.c
index 3321041..6908404 100644
--- a/drivers/isdn/hisax/ipacx.c
+++ b/drivers/isdn/hisax/ipacx.c
@@ -96,7 +96,7 @@ dch_l2l1(struct PStack *st, int pr, void *arg)
 {
 	struct IsdnCardState *cs = (struct IsdnCardState *) st->l1.hardware;
 	struct sk_buff *skb = arg;
-  u_char cda1_cr, cda2_cr;
+	u_char cda1_cr;
 
 	switch (pr) {
 		case (PH_DATA |REQUEST):
@@ -163,7 +163,7 @@ dch_l2l1(struct PStack *st, int pr, void *arg)
       cs->writeisac(cs, IPACX_CDA_TSDP10, 0x80); // Timeslot 0 is B1
       cs->writeisac(cs, IPACX_CDA_TSDP11, 0x81); // Timeslot 0 is B1
       cda1_cr = cs->readisac(cs, IPACX_CDA1_CR);
-      cda2_cr = cs->readisac(cs, IPACX_CDA2_CR);
+      (void) cs->readisac(cs, IPACX_CDA2_CR);
 			if ((long)arg &1) { // loop B1
         cs->writeisac(cs, IPACX_CDA1_CR, cda1_cr |0x0a); 
       }
-- 
1.7.4.3

