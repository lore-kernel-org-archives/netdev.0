From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 4/9] tg3: Unlock 5717 B0+ support
Date: Wed, 15 Sep 2010 11:59:56 -0700
Message-ID: <1284577201-6117-5-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1189 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755171Ab0IOTAf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Sep 2010 15:00:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adjusts the driver to use the tg3_start_xmit_dma_bug()
transmit routine for all revisions of 5717 asic rev devices and then
allows the driver to attach to B0 and later devices.

Reviewed-by: Benjamin Li <benli@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
---
 drivers/net/tg3.c |    6 +-----
 1 files changed, 1 insertions(+), 5 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index fc9706c..4e92b81 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -13431,10 +13431,6 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	if (err)
 		return err;
 
-	if (GET_ASIC_REV(tp->pci_chip_rev_id) == ASIC_REV_5717 &&
-	    tp->pci_chip_rev_id != CHIPREV_ID_5717_A0)
-		return -ENOTSUPP;
-
 	/* Initialize data/descriptor byte/word swapping. */
 	val = tr32(GRC_MODE);
 	val &= GRC_MODE_HOST_STACKUP;
@@ -14463,7 +14459,7 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 	}
 
 	if ((tp->tg3_flags3 & TG3_FLG3_5755_PLUS) &&
-	    tp->pci_chip_rev_id != CHIPREV_ID_5717_A0 &&
+	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5717 &&
 	    GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5719)
 		dev->netdev_ops = &tg3_netdev_ops;
 	else
-- 
1.7.1


