From: Roland Dreier <roland@digitalvampire.org>
Subject: Re: [PATCH] [ATM] he: Fix __init/__devinit conflict
Date: Sat, 23 Sep 2006 17:17:54 -0700
Message-ID: <87fyeit8wd.fsf@digitalvampire.org>
References: <877j0a5i6v.fsf@digitalvampire.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org,
	Chas Williams <chas@cmf.nrl.navy.mil>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rwcrmhc14.comcast.net ([216.148.227.154]:51701 "EHLO
	rwcrmhc14.comcast.net") by vger.kernel.org with ESMTP
	id S1751286AbWIXASE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Sep 2006 20:18:04 -0400
To: davem@davemloft.net
In-Reply-To: <877j0a5i6v.fsf@digitalvampire.org> (Roland Dreier's message of
 "Mon, 11 Sep 2006 12:14:48 -0700")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

he_init_one() is declared __devinit, but calls lots of init functions
that are marked __init.  However, if CONFIG_HOTPLUG is enabled,
__devinit functions go into normal .text, which leads to

    WARNING: drivers/atm/he.o - Section mismatch: reference to .init.text: from .text between 'he_start' (at offset 0x2130) and 'he_service_tbrq'

Fix this by changing the __init functions to __devinit.

Signed-off-by: Roland Dreier <roland@digitalvampire.org>

---

Dave, this was acked by Chas (and he even requested it go into 2.6.18)
but it seems to have gotten dropped somewhere -- it's not in Linus's
tree even after he pulled your net tree.

Please apply.

diff --git a/drivers/atm/he.c b/drivers/atm/he.c
index d369130..9e0383d 100644
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
