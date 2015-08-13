From: sfeldma@gmail.com
Subject: [PATCH net-next] rocker: print switch ID consistent with phys_switch_id sysfs node
Date: Wed, 12 Aug 2015 18:44:13 -0700
Message-ID: <1439430253-49275-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:35003 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751240AbbHMBlp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2015 21:41:45 -0400
Received: by pacgr6 with SMTP id gr6so26098609pac.2
        for <netdev@vger.kernel.org>; Wed, 12 Aug 2015 18:41:44 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

On sucessful probe, driver prints the switch ID.  This patch changes the
format of the printed ID to match what's used in sysfs phys_switch_id node.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 drivers/net/ethernet/rocker/rocker.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 619b2e2..d963cdc 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -5193,7 +5193,8 @@ static int rocker_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 		goto err_probe_ports;
 	}
 
-	dev_info(&pdev->dev, "Rocker switch with id %016llx\n", rocker->hw.id);
+	dev_info(&pdev->dev, "Rocker switch with id %*phN\n",
+		 (int)sizeof(rocker->hw.id), &rocker->hw.id);
 
 	return 0;
 
-- 
1.7.10.4
