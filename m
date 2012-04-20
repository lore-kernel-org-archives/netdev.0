From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH v3.4-rc 6/9] pch_gbe: do not set the channel control register
Date: Fri, 20 Apr 2012 22:09:25 +0200
Message-ID: <720be7503b68a59d5152fa929f3639846edae6f7.1334949388.git.richardcochran@gmail.com>
References: <cover.1334949388.git.richardcochran@gmail.com>
Cc: David Miller <davem@davemloft.net>,
	Takahiro Shimizu <tshimizu818@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:57249 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751976Ab2DTUKQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Apr 2012 16:10:16 -0400
Received: by mail-wi0-f178.google.com with SMTP id hq7so1034853wib.1
        for <netdev@vger.kernel.org>; Fri, 20 Apr 2012 13:10:15 -0700 (PDT)
In-Reply-To: <cover.1334949388.git.richardcochran@gmail.com>
In-Reply-To: <cover.1334949388.git.richardcochran@gmail.com>
References: <cover.1334949388.git.richardcochran@gmail.com>
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
