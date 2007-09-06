From: Andy Gospodarek <andy@greyhouse.net>
Subject: [PATCH 2.6.24 1/1] tg3: remove sparse warnings
Date: Thu, 6 Sep 2007 15:07:40 -0400
Message-ID: <20070906190739.GA10916@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Chan <mchan@broadcom.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:60603 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752622AbXIFTHq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Sep 2007 15:07:46 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Removed sparse warnings from tg3 driver.  The new logic seems fine (I
don't immediately see where we are running over values for any of the
variables that need to be saved).

This patch compiles fine and I'm currently using a tg3 with the patched
driver to post this patch as a basic proof of concept.

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
Cc: Michael Chan <mchan@broadcom.com>
Cc: Stephen Hemminger <shemminger@linux-foundation.org>
Cc: David S. Miller <davem@davemloft.net>

---

 tg3.c |   13 +++++--------
 1 files changed, 5 insertions(+), 8 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 5874042..89f391f 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -4880,7 +4880,6 @@ static void tg3_restore_pci_state(struct tg3 *tp)
 	pci_write_config_dword(tp->pdev, TG3PCI_X_CAPS, val);
 
 	if (tp->tg3_flags2 & TG3_FLG2_5780_CLASS) {
-		u32 val;
 
 		/* Chip reset on 5780 will reset MSI enable bit,
 		 * so need to restore it.
@@ -5037,7 +5036,7 @@ static int tg3_chip_reset(struct tg3 *tp)
 	tw32(GRC_MODE, tp->grc_mode);
 
 	if (tp->pci_chip_rev_id == CHIPREV_ID_5705_A0) {
-		u32 val = tr32(0xc4);
+		val = tr32(0xc4);
 
 		tw32(0xc4, val | (1 << 15));
 	}
@@ -5066,7 +5065,7 @@ static int tg3_chip_reset(struct tg3 *tp)
 
 	if ((tp->tg3_flags2 & TG3_FLG2_PCI_EXPRESS) &&
 	    tp->pci_chip_rev_id != CHIPREV_ID_5750_A0) {
-		u32 val = tr32(0x7c00);
+		val = tr32(0x7c00);
 
 		tw32(0x7c00, val | (1 << 25));
 	}
@@ -7991,7 +7990,7 @@ static int tg3_set_eeprom(struct net_device *dev, struct ethtool_eeprom *eeprom,
 	buf = data;
 	if (b_offset || odd_len) {
 		buf = kmalloc(len, GFP_KERNEL);
-		if (buf == 0)
+		if (!buf)
 			return -ENOMEM;
 		if (b_offset)
 			memcpy(buf, &start, 4);
@@ -8420,7 +8419,7 @@ static void tg3_get_ethtool_stats (struct net_device *dev,
 static int tg3_test_nvram(struct tg3 *tp)
 {
 	u32 *buf, csum, magic;
-	int i, j, err = 0, size;
+	int i, j, k, err = 0, size;
 
 	if (tg3_nvram_read_swab(tp, 0, &magic) != 0)
 		return -EIO;
@@ -8474,7 +8473,6 @@ static int tg3_test_nvram(struct tg3 *tp)
 		u8 data[NVRAM_SELFBOOT_DATA_SIZE];
 	       	u8 parity[NVRAM_SELFBOOT_DATA_SIZE];
 		u8 *buf8 = (u8 *) buf;
-		int j, k;
 
 		/* Separate the parity bits and the data bytes.  */
 		for (i = 0, j = 0, k = 0; i < NVRAM_SELFBOOT_HW_SIZE; i++) {
@@ -10730,7 +10728,6 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 		 */
 		if (GET_CHIP_REV(tp->pci_chip_rev_id) == CHIPREV_5700_BX) {
 			u32 pm_reg;
-			u16 pci_cmd;
 
 			tp->tg3_flags |= TG3_FLAG_PCIX_TARGET_HWBUG;
 
@@ -11876,7 +11873,7 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 	INIT_WORK(&tp->reset_task, tg3_reset_task);
 
 	tp->regs = ioremap_nocache(tg3reg_base, tg3reg_len);
-	if (tp->regs == 0UL) {
+	if (!tp->regs) {
 		printk(KERN_ERR PFX "Cannot map device registers, "
 		       "aborting.\n");
 		err = -ENOMEM;
