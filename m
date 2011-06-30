From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next-2.6 3/3] be2net: clear intr bit in be_probe()
Date: Thu, 30 Jun 2011 15:03:37 +0530
Message-ID: <1309426417-15931-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:15856 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753685Ab1F3Jdf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2011 05:33:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It may be set in the card while the driver is probed by kdump kernel after a
crash.

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/benet/be_main.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 5b319d7..375924f 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -3417,6 +3417,12 @@ static int __devinit be_probe(struct pci_dev *pdev,
 	if (status)
 		goto stats_clean;
 
+	/* The INTR bit may be set in the card when probed by a kdump kernel
+	 * after a crash.
+ 	 */ 
+	if (!lancer_chip(adapter))
+		be_intr_set(adapter, false);
+
 	be_msix_enable(adapter);
 
 	INIT_DELAYED_WORK(&adapter->work, be_worker);
-- 
1.7.4

