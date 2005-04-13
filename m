From: "John W. Linville" <linville@tuxdriver.com>
Subject: [patch 2.6.12-rc2 8/10] tg3: use TG3_FLG2_57{05,50}_PLUS flags in tg3_get_invariants
Date: Wed, 13 Apr 2005 19:38:45 -0400
Message-ID: <04132005193845.8775@laptop>
References: <04132005193845.8720@laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
In-Reply-To: <04132005193845.8720@laptop>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Rewrite checks in tg3_get_invariants to use TG3_FLG2_5705_PLUS and
TG3_FLG2_5750_PLUS flags.

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---

 drivers/net/tg3.c |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)

--- bcm5752-support/drivers/net/tg3.c.orig	2005-04-08 18:11:46.207874683 -0400
+++ bcm5752-support/drivers/net/tg3.c	2005-04-08 18:11:36.696183379 -0400
@@ -7937,8 +7937,7 @@ static int __devinit tg3_get_invariants(
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5752)
 		tp->tg3_flags2 |= TG3_FLG2_5750_PLUS;
 
-	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5750 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5752)
+	if (tp->tg3_flags2 & TG3_FLG2_5750_PLUS)
 		tp->tg3_flags2 |= TG3_FLG2_HW_TSO;
 
 	if (pci_find_capability(tp->pdev, PCI_CAP_ID_EXP) != 0)
@@ -8068,9 +8067,7 @@ static int __devinit tg3_get_invariants(
 	if (tp->pci_chip_rev_id == CHIPREV_ID_5704_A0)
 		tp->tg3_flags2 |= TG3_FLG2_PHY_5704_A0_BUG;
 
-	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5705 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5750 ||
-	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5752)
+	if (tp->tg3_flags2 & TG3_FLG2_5705_PLUS)
 		tp->tg3_flags2 |= TG3_FLG2_PHY_BER_BUG;
 
 	/* Only 5701 and later support tagged irq status mode.
