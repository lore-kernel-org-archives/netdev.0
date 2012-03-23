From: Takahiro Shimizu <tshimizu818@gmail.com>
Subject: [PATCH 1/2] ptp/ptp_pch: Modified according to the mainter's comments
Date: Fri, 23 Mar 2012 11:12:39 +0900
Message-ID: <1332468760-2525-1-git-send-email-tshimizu818@gmail.com>
Cc: qi.wang@intel.com, yong.y.wang@intel.com, joel.clark@intel.com,
	kok.howg.ewe@intel.com, Takahiro Shimizu <tshimizu818@gmail.com>
To: jeffrey.t.kirsher@intel.com, davem@davemloft.net,
	lucas.demarchi@profusion.mobi, mirq-linux@rere.qmqm.pl,
	paul.gortmaker@windriver.com, jdmason@kudzu.us,
	john.stultz@linaro.org, richardcochran@gmail.com, arnd@arndb.de,
	khc@pm.waw.pl, netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:62522 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751250Ab2CWCMt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Mar 2012 22:12:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Takahiro Shimizu <tshimizu818@gmail.com>
---
 drivers/ptp/ptp_pch.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/ptp/ptp_pch.c b/drivers/ptp/ptp_pch.c
index 375eb04..212381e 100644
--- a/drivers/ptp/ptp_pch.c
+++ b/drivers/ptp/ptp_pch.c
@@ -261,6 +261,7 @@ u64 pch_rx_snap_read(struct pci_dev *pdev)
 
 	ns = ((u64) hi) << 32;
 	ns |= lo;
+	ns <<= TICKS_NS_SHIFT;
 
 	return ns;
 }
@@ -277,6 +278,7 @@ u64 pch_tx_snap_read(struct pci_dev *pdev)
 
 	ns = ((u64) hi) << 32;
 	ns |= lo;
+	ns <<= TICKS_NS_SHIFT;
 
 	return ns;
 }
@@ -649,8 +651,6 @@ pch_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 	iowrite32(1, &chip->regs->trgt_lo);
 	iowrite32(0, &chip->regs->trgt_hi);
 	iowrite32(PCH_TSE_TTIPEND, &chip->regs->event);
-	/* Version: IEEE1588 v1 and IEEE1588-2008,  Mode: All Evwnt, Locked  */
-	iowrite32(0x80020000, &chip->regs->ch_control);
 
 	pch_eth_enable_set(chip);
 
-- 
1.7.4.4
