From: David Miller <davem@davemloft.net>
Subject: [PATCH 18/42] isdn: arcofi: Fix set-but-unused variables.
Date: Sun, 17 Apr 2011 17:33:28 -0700 (PDT)
Message-ID: <20110417.173328.232743046.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51039
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752320Ab1DRAeC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Apr 2011 20:34:02 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 30E7C24C089
	for <netdev@vger.kernel.org>; Sun, 17 Apr 2011 17:33:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The variable 'val' is set but unused in
send_arcofi().  Just kill it off.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/isdn/hisax/arcofi.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/drivers/isdn/hisax/arcofi.c b/drivers/isdn/hisax/arcofi.c
index 85a8fd8..21cbbe1 100644
--- a/drivers/isdn/hisax/arcofi.c
+++ b/drivers/isdn/hisax/arcofi.c
@@ -30,8 +30,6 @@ add_arcofi_timer(struct IsdnCardState *cs) {
 
 static void
 send_arcofi(struct IsdnCardState *cs) {
-	u_char val;
-	
 	add_arcofi_timer(cs);
 	cs->dc.isac.mon_txp = 0;
 	cs->dc.isac.mon_txc = cs->dc.isac.arcofi_list->len;
@@ -45,7 +43,7 @@ send_arcofi(struct IsdnCardState *cs) {
 	cs->dc.isac.mocr &= 0x0f;
 	cs->dc.isac.mocr |= 0xa0;
 	cs->writeisac(cs, ISAC_MOCR, cs->dc.isac.mocr);
-	val = cs->readisac(cs, ISAC_MOSR);
+	(void) cs->readisac(cs, ISAC_MOSR);
 	cs->writeisac(cs, ISAC_MOX1, cs->dc.isac.mon_tx[cs->dc.isac.mon_txp++]);
 	cs->dc.isac.mocr |= 0x10;
 	cs->writeisac(cs, ISAC_MOCR, cs->dc.isac.mocr);
-- 
1.7.4.3

