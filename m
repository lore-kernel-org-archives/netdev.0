From: kpark3469@gmail.com
Subject: [PATCH v2] ptp_pch: eliminate a number of sparse warnings
Date: Wed, 27 Mar 2013 14:07:23 +0900
Message-ID: <1364360843-6777-1-git-send-email-kpark3469@gmail.com>
Cc: keun-o.park@windriver.com, netdev@vger.kernel.org,
	kpark3469@gmail.com, davem@davemloft.net
To: richardcochran@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f54.google.com ([209.85.214.54]:55938 "EHLO
	mail-bk0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751988Ab3C0FHj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Mar 2013 01:07:39 -0400
Received: by mail-bk0-f54.google.com with SMTP id q16so1262551bkw.41
        for <netdev@vger.kernel.org>; Tue, 26 Mar 2013 22:07:37 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sahara <keun-o.park@windriver.com>

This fixes a number of sparse warnings like:
  warning: incorrect type in argument 2 (different address spaces)
    expected void volatile [noderef] <asn:2>*addr
    got unsigned int *<noident>

  warning: Using plain integer as NULL pointer

Additionally this fixes a warning from checkpatch.pl like:
  WARNING: sizeof pch_param.station should be sizeof(pch_param.station)

Signed-off-by: Sahara <keun-o.park@windriver.com>
---
 drivers/ptp/ptp_pch.c |   27 ++++++++++++++-------------
 1 files changed, 14 insertions(+), 13 deletions(-)

diff --git a/drivers/ptp/ptp_pch.c b/drivers/ptp/ptp_pch.c
index 1367655..6b4e3ad 100644
--- a/drivers/ptp/ptp_pch.c
+++ b/drivers/ptp/ptp_pch.c
@@ -118,7 +118,7 @@ struct pch_ts_regs {
  * struct pch_dev - Driver private data
  */
 struct pch_dev {
-	struct pch_ts_regs *regs;
+	struct pch_ts_regs __iomem *regs;
 	struct ptp_clock *ptp_clock;
 	struct ptp_clock_info caps;
 	int exts0_enabled;
@@ -154,7 +154,7 @@ static inline void pch_eth_enable_set(struct pch_dev *chip)
 	iowrite32(val, (&chip->regs->ts_sel));
 }
 
-static u64 pch_systime_read(struct pch_ts_regs *regs)
+static u64 pch_systime_read(struct pch_ts_regs __iomem *regs)
 {
 	u64 ns;
 	u32 lo, hi;
@@ -169,7 +169,7 @@ static u64 pch_systime_read(struct pch_ts_regs *regs)
 	return ns;
 }
 
-static void pch_systime_write(struct pch_ts_regs *regs, u64 ns)
+static void pch_systime_write(struct pch_ts_regs __iomem *regs, u64 ns)
 {
 	u32 hi, lo;
 
@@ -315,7 +315,7 @@ int pch_set_station_address(u8 *addr, struct pci_dev *pdev)
 	struct pch_dev *chip = pci_get_drvdata(pdev);
 
 	/* Verify the parameter */
-	if ((chip->regs == 0) || addr == (u8 *)NULL) {
+	if ((chip->regs == NULL) || addr == (u8 *)NULL) {
 		dev_err(&pdev->dev,
 			"invalid params returning PCH_INVALIDPARAM\n");
 		return PCH_INVALIDPARAM;
@@ -361,7 +361,7 @@ EXPORT_SYMBOL(pch_set_station_address);
 static irqreturn_t isr(int irq, void *priv)
 {
 	struct pch_dev *pch_dev = priv;
-	struct pch_ts_regs *regs = pch_dev->regs;
+	struct pch_ts_regs __iomem *regs = pch_dev->regs;
 	struct ptp_clock_event event;
 	u32 ack = 0, lo, hi, val;
 
@@ -415,7 +415,7 @@ static int ptp_pch_adjfreq(struct ptp_clock_info *ptp, s32 ppb)
 	u32 diff, addend;
 	int neg_adj = 0;
 	struct pch_dev *pch_dev = container_of(ptp, struct pch_dev, caps);
-	struct pch_ts_regs *regs = pch_dev->regs;
+	struct pch_ts_regs __iomem *regs = pch_dev->regs;
 
 	if (ppb < 0) {
 		neg_adj = 1;
@@ -438,7 +438,7 @@ static int ptp_pch_adjtime(struct ptp_clock_info *ptp, s64 delta)
 	s64 now;
 	unsigned long flags;
 	struct pch_dev *pch_dev = container_of(ptp, struct pch_dev, caps);
-	struct pch_ts_regs *regs = pch_dev->regs;
+	struct pch_ts_regs __iomem *regs = pch_dev->regs;
 
 	spin_lock_irqsave(&pch_dev->register_lock, flags);
 	now = pch_systime_read(regs);
@@ -455,7 +455,7 @@ static int ptp_pch_gettime(struct ptp_clock_info *ptp, struct timespec *ts)
 	u32 remainder;
 	unsigned long flags;
 	struct pch_dev *pch_dev = container_of(ptp, struct pch_dev, caps);
-	struct pch_ts_regs *regs = pch_dev->regs;
+	struct pch_ts_regs __iomem *regs = pch_dev->regs;
 
 	spin_lock_irqsave(&pch_dev->register_lock, flags);
 	ns = pch_systime_read(regs);
@@ -472,7 +472,7 @@ static int ptp_pch_settime(struct ptp_clock_info *ptp,
 	u64 ns;
 	unsigned long flags;
 	struct pch_dev *pch_dev = container_of(ptp, struct pch_dev, caps);
-	struct pch_ts_regs *regs = pch_dev->regs;
+	struct pch_ts_regs __iomem *regs = pch_dev->regs;
 
 	ns = ts->tv_sec * 1000000000ULL;
 	ns += ts->tv_nsec;
@@ -567,9 +567,9 @@ static void pch_remove(struct pci_dev *pdev)
 		free_irq(pdev->irq, chip);
 
 	/* unmap the virtual IO memory space */
-	if (chip->regs != 0) {
+	if (chip->regs != NULL) {
 		iounmap(chip->regs);
-		chip->regs = 0;
+		chip->regs = NULL;
 	}
 	/* release the reserved IO memory space */
 	if (chip->mem_base != 0) {
@@ -670,7 +670,7 @@ pch_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 err_req_irq:
 	ptp_clock_unregister(chip->ptp_clock);
 	iounmap(chip->regs);
-	chip->regs = 0;
+	chip->regs = NULL;
 
 err_ioremap:
 	release_mem_region(chip->mem_base, chip->mem_size);
@@ -723,7 +723,8 @@ static s32 __init ptp_pch_init(void)
 module_init(ptp_pch_init);
 module_exit(ptp_pch_exit);
 
-module_param_string(station, pch_param.station, sizeof pch_param.station, 0444);
+module_param_string(station,
+		    pch_param.station, sizeof(pch_param.station), 0444);
 MODULE_PARM_DESC(station,
 	 "IEEE 1588 station address to use - column separated hex values");
 
-- 
1.7.1
