From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next] ixp4xx_eth: Fix up the get_ts_info ethtool method.
Date: Sat,  7 Apr 2012 17:56:10 +0200
Message-ID: <1333814170-30940-1-git-send-email-richardcochran@gmail.com>
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:37553 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753554Ab2DGP4V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Apr 2012 11:56:21 -0400
Received: by wibhj6 with SMTP id hj6so1268408wib.1
        for <netdev@vger.kernel.org>; Sat, 07 Apr 2012 08:56:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit e77bd1ec121ee4163a6b42a44e87b2e382c39e04 added support for a
new ethtool function, but that cannot compile due to a misnamed global
variable. Not that it really matters (since the IXP4xx does compile
either, as of about Linux 3.1) but just in case, this patch fixes the
misnamed variable in the PHC driver.

Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/ptp/ptp_ixp46x.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/ptp/ptp_ixp46x.c b/drivers/ptp/ptp_ixp46x.c
index 9d13a71..e03c406 100644
--- a/drivers/ptp/ptp_ixp46x.c
+++ b/drivers/ptp/ptp_ixp46x.c
@@ -284,7 +284,7 @@ static void __exit ptp_ixp_exit(void)
 {
 	free_irq(MASTER_IRQ, &ixp_clock);
 	free_irq(SLAVE_IRQ, &ixp_clock);
-	ixp46x_phc_clock = -1;
+	ixp46x_phc_index = -1;
 	ptp_clock_unregister(ixp_clock.ptp_clock);
 }
 
@@ -303,7 +303,7 @@ static int __init ptp_ixp_init(void)
 	if (IS_ERR(ixp_clock.ptp_clock))
 		return PTR_ERR(ixp_clock.ptp_clock);
 
-	ixp46x_phc_clock = ptp_clock_index(ixp_clock.ptp_clock);
+	ixp46x_phc_index = ptp_clock_index(ixp_clock.ptp_clock);
 
 	__raw_writel(DEFAULT_ADDEND, &ixp_clock.regs->addend);
 	__raw_writel(1, &ixp_clock.regs->trgt_lo);
-- 
1.7.2.5
