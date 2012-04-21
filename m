From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH net-next 6/9] pch_gbe: do not set the channel control register
Date: Sat, 21 Apr 2012 06:50:33 +0200
Message-ID: <32548d7c716e8fa85ac5e50427208ec72b3c96c6.1334983471.git.richardcochran@gmail.com>
References: <cover.1334983471.git.richardcochran@gmail.com>
Cc: David Miller <davem@davemloft.net>,
	Takahiro Shimizu <tshimizu818@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:57150 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752273Ab2DUEvF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Apr 2012 00:51:05 -0400
Received: by wejx9 with SMTP id x9so6444663wej.19
        for <netdev@vger.kernel.org>; Fri, 20 Apr 2012 21:51:04 -0700 (PDT)
In-Reply-To: <cover.1334983471.git.richardcochran@gmail.com>
In-Reply-To: <cover.1334983471.git.richardcochran@gmail.com>
References: <cover.1334983471.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Takahiro Shimizu <tshimizu818@gmail.com>

We will let the pch_gbe code do that according to the receive time stamp
filter.

[ RC - Rebased Takahiro's changes and wrote a commit message
  explaining the changes. ]

Signed-off-by: Takahiro Shimizu <tshimizu818@gmail.com>
Signed-off-by: Richard Cochran <richardcochran@gmail.com>
---
 drivers/ptp/ptp_pch.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/ptp/ptp_pch.c b/drivers/ptp/ptp_pch.c
index 9e397fe..08c3311 100644
--- a/drivers/ptp/ptp_pch.c
+++ b/drivers/ptp/ptp_pch.c
@@ -652,8 +652,6 @@ pch_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 	iowrite32(1, &chip->regs->trgt_lo);
 	iowrite32(0, &chip->regs->trgt_hi);
 	iowrite32(PCH_TSE_TTIPEND, &chip->regs->event);
-	/* Version: IEEE1588 v1 and IEEE1588-2008,  Mode: All Evwnt, Locked  */
-	iowrite32(0x80020000, &chip->regs->ch_control);
 
 	pch_eth_enable_set(chip);
 
-- 
1.7.2.5
