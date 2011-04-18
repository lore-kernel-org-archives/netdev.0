From: David Miller <davem@davemloft.net>
Subject: [PATCH 16/42] isdn: hfcpci: Fix set-but-unused variables.
Date: Sun, 17 Apr 2011 17:33:22 -0700 (PDT)
Message-ID: <20110417.173322.245393686.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51033
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753926Ab1DRAd5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Apr 2011 20:33:57 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 1F55E24C087
	for <netdev@vger.kernel.org>; Sun, 17 Apr 2011 17:33:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The variable 'total' is set but unused in
hfcpci_empty_bfifo().  Just kill it off.

Similarly for the variable 'val' in ph_state_nt().

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/isdn/hardware/mISDN/hfcpci.c |    6 ++----
 1 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/isdn/hardware/mISDN/hfcpci.c b/drivers/isdn/hardware/mISDN/hfcpci.c
index 4343aba..b01a7be 100644
--- a/drivers/isdn/hardware/mISDN/hfcpci.c
+++ b/drivers/isdn/hardware/mISDN/hfcpci.c
@@ -405,7 +405,7 @@ hfcpci_empty_bfifo(struct bchannel *bch, struct bzfifo *bz,
     u_char *bdata, int count)
 {
 	u_char		*ptr, *ptr1, new_f2;
-	int		total, maxlen, new_z2;
+	int		maxlen, new_z2;
 	struct zt	*zp;
 
 	if ((bch->debug & DEBUG_HW_BCHANNEL) && !(bch->debug & DEBUG_HW_BFIFO))
@@ -431,7 +431,6 @@ hfcpci_empty_bfifo(struct bchannel *bch, struct bzfifo *bz,
 			printk(KERN_WARNING "HFCPCI: receive out of memory\n");
 			return;
 		}
-		total = count;
 		count -= 3;
 		ptr = skb_put(bch->rx_skb, count);
 
@@ -968,7 +967,6 @@ static void
 ph_state_nt(struct dchannel *dch)
 {
 	struct hfc_pci	*hc = dch->hw;
-	u_char	val;
 
 	if (dch->debug)
 		printk(KERN_DEBUG "%s: NT newstate %x\n",
@@ -982,7 +980,7 @@ ph_state_nt(struct dchannel *dch)
 			hc->hw.int_m1 &= ~HFCPCI_INTS_TIMER;
 			Write_hfc(hc, HFCPCI_INT_M1, hc->hw.int_m1);
 			/* Clear already pending ints */
-			val = Read_hfc(hc, HFCPCI_INT_S1);
+			(void) Read_hfc(hc, HFCPCI_INT_S1);
 			Write_hfc(hc, HFCPCI_STATES, 4 | HFCPCI_LOAD_STATE);
 			udelay(10);
 			Write_hfc(hc, HFCPCI_STATES, 4);
-- 
1.7.4.3

