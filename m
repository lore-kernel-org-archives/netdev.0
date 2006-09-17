From: "chas williams - CONTRACTOR" <chas@cmf.nrl.navy.mil>
Subject: [PATCH 1/3][ATM]: [he] he_init_one() is declared __devinit, but calls __init functions
Date: Sat, 16 Sep 2006 20:18:25 -0400
Message-ID: <200609170018.k8H0IPxV025280@cmf.nrl.navy.mil>
Cc: davem@davemloft.net, Roland Dreier <roland@digitalvampire.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ginger.cmf.nrl.navy.mil ([134.207.10.161]:64936 "EHLO
	ginger.cmf.nrl.navy.mil") by vger.kernel.org with ESMTP
	id S964844AbWIQASu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 16 Sep 2006 20:18:50 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

please consider for 2.6.18 -- thanks!

[ATM]: [he] he_init_one() is declared __devinit, but calls __init functions

he_init_one() is declared __devinit, but calls lots of init functions
that are marked __init.  However, if CONFIG_HOTPLUG is enabled,
__devinit functions go into normal .text, which leads to

    WARNING: drivers/atm/he.o - Section mismatch: reference to .init.text:
from .text between 'he_start' (at offset 0x2130) and 'he_service_tbrq'

Fix this by changing the __init functions to __devinit.

Signed-off-by: Roland Dreier <roland@digitalvampire.org>
Signed-off-by: Chas Williams <chas@cmf.nrl.navy.mil>

---
commit c0361a8558796e5af9c5d4e8d4900e4dc44c2e4e
tree 9ad8e4378eb731b220f1e91f1d92b3122f4d6565
parent 96086141b3a9dcde8f0946ae01f9faa55ac0bf4d
author chas williams - CONTRACTOR <chas@thirdoffive.cmf.nrl.navy.mil> Sat, 16 Sep 2006 15:44:55 -0400
committer chas williams - CONTRACTOR <chas@thirdoffive.cmf.nrl.navy.mil> Sat, 16 Sep 2006 15:44:55 -0400

 drivers/atm/he.c |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/atm/he.c b/drivers/atm/he.c
index dd96123..4598b1f 100644
--- a/drivers/atm/he.c
+++ b/drivers/atm/he.c
@@ -454,7 +454,7 @@ #define NONZERO (1 << 14)
 	return (NONZERO | (exp << 9) | (rate & 0x1ff));
 }
 
-static void __init
+static void __devinit
 he_init_rx_lbfp0(struct he_dev *he_dev)
 {
 	unsigned i, lbm_offset, lbufd_index, lbuf_addr, lbuf_count;
@@ -485,7 +485,7 @@ he_init_rx_lbfp0(struct he_dev *he_dev)
 	he_writel(he_dev, he_dev->r0_numbuffs, RLBF0_C);
 }
 
-static void __init
+static void __devinit
 he_init_rx_lbfp1(struct he_dev *he_dev)
 {
 	unsigned i, lbm_offset, lbufd_index, lbuf_addr, lbuf_count;
@@ -516,7 +516,7 @@ he_init_rx_lbfp1(struct he_dev *he_dev)
 	he_writel(he_dev, he_dev->r1_numbuffs, RLBF1_C);
 }
 
-static void __init
+static void __devinit
 he_init_tx_lbfp(struct he_dev *he_dev)
 {
 	unsigned i, lbm_offset, lbufd_index, lbuf_addr, lbuf_count;
@@ -546,7 +546,7 @@ he_init_tx_lbfp(struct he_dev *he_dev)
 	he_writel(he_dev, lbufd_index - 1, TLBF_T);
 }
 
-static int __init
+static int __devinit
 he_init_tpdrq(struct he_dev *he_dev)
 {
 	he_dev->tpdrq_base = pci_alloc_consistent(he_dev->pci_dev,
@@ -568,7 +568,7 @@ he_init_tpdrq(struct he_dev *he_dev)
 	return 0;
 }
 
-static void __init
+static void __devinit
 he_init_cs_block(struct he_dev *he_dev)
 {
 	unsigned clock, rate, delta;
@@ -664,7 +664,7 @@ he_init_cs_block(struct he_dev *he_dev)
 
 }
 
-static int __init
+static int __devinit
 he_init_cs_block_rcm(struct he_dev *he_dev)
 {
 	unsigned (*rategrid)[16][16];
@@ -785,7 +785,7 @@ #define RTGTBL_OFFSET 0x400
 	return 0;
 }
 
-static int __init
+static int __devinit
 he_init_group(struct he_dev *he_dev, int group)
 {
 	int i;
@@ -955,7 +955,7 @@ #endif
 	return 0;
 }
 
-static int __init
+static int __devinit
 he_init_irq(struct he_dev *he_dev)
 {
 	int i;
