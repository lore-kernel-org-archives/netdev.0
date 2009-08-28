From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 01/17] tg3: Delay mdio bus init until fw finishes
Date: Fri, 28 Aug 2009 15:27:50 -0700
Message-ID: <1251585277.29663@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2837 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752602AbZH2Weu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Aug 2009 18:34:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The device firmware uses the MDIO bus during early setup.  If the driver
modifies the MDIO bus configuration while it is in use by the firmware,
any number of bad things can happen.  This patch delays MDIO setup until
after the firmware posts its magic signature, signifying initialization
is complete.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
---
 drivers/net/tg3.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 8af2cdf..ab3159e 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -6348,14 +6348,14 @@ static int tg3_chip_reset(struct tg3 *tp)
 		tw32_f(MAC_MODE, 0);
 	udelay(40);
 
-	tg3_mdio_start(tp);
-
 	tg3_ape_unlock(tp, TG3_APE_LOCK_GRC);
 
 	err = tg3_poll_fw(tp);
 	if (err)
 		return err;
 
+	tg3_mdio_start(tp);
+
 	if ((tp->tg3_flags2 & TG3_FLG2_PCI_EXPRESS) &&
 	    tp->pci_chip_rev_id != CHIPREV_ID_5750_A0) {
 		val = tr32(0x7c00);
-- 
1.6.3.3


