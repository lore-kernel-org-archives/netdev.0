From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 7/11][TG3]: Eliminate the TG3_FLAG_5701_REG_WRITE_BUG
 flag.
Date: Fri, 04 May 2007 17:54:17 -0700
Message-ID: <1178326457.4859.23.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4000 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1767930AbXEEAHG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 May 2007 20:07:06 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[TG3]: Eliminate the TG3_FLAG_5701_REG_WRITE_BUG flag.

This patch removes the use of the TG3_FLAG_5701_REG_WRITE_BUG flag.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 84fc498..23a9477 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -10673,17 +10673,6 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	if (GET_CHIP_REV(tp->pci_chip_rev_id) == CHIPREV_5700_BX)
 		tp->tg3_flags |= TG3_FLAG_TXD_MBOX_HWBUG;
 
-	/* Back to back register writes can cause problems on this chip,
-	 * the workaround is to read back all reg writes except those to
-	 * mailbox regs.  See tg3_write_indirect_reg32().
-	 *
-	 * PCI Express 5750_A0 rev chips need this workaround too.
-	 */
-	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5701 ||
-	    ((tp->tg3_flags2 & TG3_FLG2_PCI_EXPRESS) &&
-	     tp->pci_chip_rev_id == CHIPREV_ID_5750_A0))
-		tp->tg3_flags |= TG3_FLAG_5701_REG_WRITE_BUG;
-
 	if ((pci_state_reg & PCISTATE_BUS_SPEED_HIGH) != 0)
 		tp->tg3_flags |= TG3_FLAG_PCI_HIGH_SPEED;
 	if ((pci_state_reg & PCISTATE_BUS_32BIT) != 0)
@@ -10707,8 +10696,18 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	/* Various workaround register access methods */
 	if (tp->tg3_flags & TG3_FLAG_PCIX_TARGET_HWBUG)
 		tp->write32 = tg3_write_indirect_reg32;
-	else if (tp->tg3_flags & TG3_FLAG_5701_REG_WRITE_BUG)
+	else if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5701 ||
+		 ((tp->tg3_flags2 & TG3_FLG2_PCI_EXPRESS) &&
+		  tp->pci_chip_rev_id == CHIPREV_ID_5750_A0)) {
+		/* Back to back register writes can cause problems on this chip,
+		 * the workaround is to read back all reg writes except those to
+		 * mailbox regs.  See tg3_write_indirect_reg32().
+		 *
+		 * PCI Express 5750_A0 rev chips need this workaround too.
+		 */
 		tp->write32 = tg3_write_flush_reg32;
+	}
+
 
 	if ((tp->tg3_flags & TG3_FLAG_TXD_MBOX_HWBUG) ||
 	    (tp->tg3_flags & TG3_FLAG_MBOX_WRITE_REORDER)) {
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index dd04a46..c52acb0 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -2199,7 +2199,6 @@ struct tg3 {
 #define TG3_FLAG_USE_LINKCHG_REG	0x00000008
 #define TG3_FLAG_USE_MI_INTERRUPT	0x00000010
 #define TG3_FLAG_ENABLE_ASF		0x00000020
-#define TG3_FLAG_5701_REG_WRITE_BUG	0x00000040
 #define TG3_FLAG_POLL_SERDES		0x00000080
 #define TG3_FLAG_MBOX_WRITE_REORDER	0x00000100
 #define TG3_FLAG_PCIX_TARGET_HWBUG	0x00000200


