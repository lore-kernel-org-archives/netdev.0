From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] ptp: oops in ptp_ioctl()
Date: Thu, 26 May 2016 09:46:22 +0300
Message-ID: <20160526064622.GA6776@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Richard Cochran <richardcochran@gmail.com>,
	Muhammad Falak R Wani <falakreyaz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:20027 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750854AbcEZGqd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 May 2016 02:46:33 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If we pass ERR_PTR(-EFAULT) to kfree() then it's going to oops.

Fixes: 2ece068e1b1d ('ptp: use memdup_user().')
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/ptp/ptp_chardev.c b/drivers/ptp/ptp_chardev.c
index 0b1ac6b..d637c93 100644
--- a/drivers/ptp/ptp_chardev.c
+++ b/drivers/ptp/ptp_chardev.c
@@ -211,6 +211,7 @@ long ptp_ioctl(struct posix_clock *pc, unsigned int cmd, unsigned long arg)
 		sysoff = memdup_user((void __user *)arg, sizeof(*sysoff));
 		if (IS_ERR(sysoff)) {
 			err = PTR_ERR(sysoff);
+			sysoff = NULL;
 			break;
 		}
 		if (sysoff->n_samples > PTP_MAX_SAMPLES) {
