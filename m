From: "John W. Linville" <linville@tuxdriver.com>
Subject: [patch 2.6.12-rc2 5/10] tg3: define TG3_FLG2_5750_PLUS flag
Date: Wed, 13 Apr 2005 19:38:45 -0400
Message-ID: <04132005193845.8597@laptop>
References: <04132005193844.8539@laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, davem@davemloft.net
Return-path: <netdev-bounce@oss.sgi.com>
To: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
In-Reply-To: <04132005193844.8539@laptop>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Define TG3_FLG2_5750_PLUS flag and set it in tg3_get_invariants for
ASIC_REV_5750 or ASIC_REV_5752.

Signed-off-by: John W. Linville <linville@tuxdriver.com>
---

 drivers/net/tg3.c |    4 ++++
 drivers/net/tg3.h |    1 +
 2 files changed, 5 insertions(+)

--- bcm5752-support/drivers/net/tg3.c.orig	2005-04-08 17:47:31.186930125 -0400
+++ bcm5752-support/drivers/net/tg3.c	2005-04-08 17:47:16.409928291 -0400
@@ -7951,6 +7951,10 @@ static int __devinit tg3_get_invariants(
 
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5750 ||
 	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5752)
+		tp->tg3_flags2 |= TG3_FLG2_5750_PLUS;
+
+	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5750 ||
+	    GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5752)
 		tp->tg3_flags2 |= TG3_FLG2_HW_TSO;
 
 	if (pci_find_capability(tp->pdev, PCI_CAP_ID_EXP) != 0)
--- bcm5752-support/drivers/net/tg3.h.orig	2005-04-08 17:47:35.536341972 -0400
+++ bcm5752-support/drivers/net/tg3.h	2005-04-08 17:44:48.578234813 -0400
@@ -2101,6 +2101,7 @@ struct tg3 {
 #define TG3_FLG2_HW_TSO			0x00010000
 #define TG3_FLG2_SERDES_PREEMPHASIS	0x00020000
 #define TG3_FLG2_5705_PLUS		0x00040000
+#define TG3_FLG2_5750_PLUS		0x00080000
 
 	u32				split_mode_max_reqs;
 #define SPLIT_MODE_5704_MAX_REQ		3
