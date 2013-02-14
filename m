From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 4/5 net-next] tg3: Set initial carrier state to off.
Date: Thu, 14 Feb 2013 14:13:41 -0800
Message-ID: <1360880022-12856-4-git-send-email-mchan@broadcom.com>
References: <1360880022-12856-1-git-send-email-mchan@broadcom.com>
 <1360880022-12856-2-git-send-email-mchan@broadcom.com>
 <1360880022-12856-3-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nsujir@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4439 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932628Ab3BNV4b (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Feb 2013 16:56:31 -0500
In-Reply-To: <1360880022-12856-3-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Before the device is opened, the carrier state should be off.  It
will not race with the link interrupt if we set it before calling
register_netdev().

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 7ac0bd0..3829321 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -16902,6 +16902,8 @@ static int tg3_init_one(struct pci_dev *pdev,
 
 	tg3_timer_init(tp);
 
+	tg3_carrier_off(tp);
+
 	err = register_netdev(dev);
 	if (err) {
 		dev_err(&pdev->dev, "Cannot register net device, aborting\n");
-- 
1.7.1
