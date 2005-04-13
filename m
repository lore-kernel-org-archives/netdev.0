From: "John W. Linville" <linville@tuxdriver.com>
Subject: [patch 2.6.12-rc2 7/10] tg3: more use of TG3_FLG2_5705_PLUS flag
Date: Wed, 13 Apr 2005 19:38:45 -0400
Message-ID: <04132005193845.8720@laptop>
References: <04132005193845.8656@laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
In-Reply-To: <04132005193845.8656@laptop>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Rewrite of a couple of troublesome multi-way if statements to use
TG3_FLG2_5705_PLUS flag.

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---

 drivers/net/tg3.c |   12 ++++--------
 1 files changed, 4 insertions(+), 8 deletions(-)

--- bcm5752-support/drivers/net/tg3.c.orig	2005-04-08 18:00:31.886220435 -0400
+++ bcm5752-support/drivers/net/tg3.c	2005-04-08 18:08:55.969298725 -0400
@@ -5237,10 +5237,8 @@ static int tg3_reset_hw(struct tg3 *tp)
 		      RDMAC_MODE_LNGREAD_ENAB);
 	if (tp->tg3_flags & TG3_FLAG_SPLIT_MODE)
 		rdmac_mode |= RDMAC_MODE_SPLIT_ENABLE;
-	if ((GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5705 &&
-	     tp->pci_chip_rev_id != CHIPREV_ID_5705_A0) ||
-	    (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5750 ||
-	     GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5752)) {
+	if ((tp->tg3_flags2 & TG3_FLG2_5705_PLUS) &&
+	     tp->pci_chip_rev_id != CHIPREV_ID_5705_A0) {
 		if (tp->tg3_flags2 & TG3_FLG2_TSO_CAPABLE &&
 		    (tp->pci_chip_rev_id == CHIPREV_ID_5705_A1 ||
 		     tp->pci_chip_rev_id == CHIPREV_ID_5705_A2)) {
@@ -5353,10 +5351,8 @@ static int tg3_reset_hw(struct tg3 *tp)
 	       WDMAC_MODE_FIFOURUN_ENAB | WDMAC_MODE_FIFOOREAD_ENAB |
 	       WDMAC_MODE_LNGREAD_ENAB);
 
-	if ((GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5705 &&
-	     tp->pci_chip_rev_id != CHIPREV_ID_5705_A0) ||
-	    (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5750 ||
-	     GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5752)) {
+	if ((tp->tg3_flags2 & TG3_FLG2_5705_PLUS) &&
+	     tp->pci_chip_rev_id != CHIPREV_ID_5705_A0) {
 		if ((tp->tg3_flags & TG3_FLG2_TSO_CAPABLE) &&
 		    (tp->pci_chip_rev_id == CHIPREV_ID_5705_A1 ||
 		     tp->pci_chip_rev_id == CHIPREV_ID_5705_A2)) {
