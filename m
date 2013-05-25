From: Kyle McMartin <kyle@redhat.com>
Subject: [PATCH] ptp_pch: depends on PCI
Date: Sat, 25 May 2013 12:55:07 -0400
Message-ID: <20130525165507.GE30204@redacted.bos.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: richardcochran@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53601 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757137Ab3EYQzL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 25 May 2013 12:55:11 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It's only accessible via PCI, but has no dependencies, so it ends up
being selected on s390 where a bunch of primitives only exist if
CONFIG_PCI=y (such as {request,free}_irq)

Signed-off-by: Kyle McMartin <kyle@redhat.com>

--- a/drivers/ptp/Kconfig
+++ b/drivers/ptp/Kconfig
@@ -72,6 +72,7 @@ config DP83640_PHY
 
 config PTP_1588_CLOCK_PCH
 	tristate "Intel PCH EG20T as PTP clock"
+	depends on PCI
 	select PTP_1588_CLOCK
 	help
 	  This driver adds support for using the PCH EG20T as a PTP
