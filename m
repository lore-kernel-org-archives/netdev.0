From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 8/8] rocker: Request a dump of FIB tables during init
Date: Wed, 16 Nov 2016 15:09:03 +0100
Message-ID: <1479305343-13167-9-git-send-email-jiri@resnulli.us>
References: <1479305343-13167-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, arkadis@mellanox.com,
        ogerlitz@mellanox.com, roopa@cumulusnetworks.com,
        dsa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        andy@greyhouse.net, vivien.didelot@savoirfairelinux.com,
        andrew@lunn.ch, f.fainelli@gmail.com, alexander.h.duyck@intel.com,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33040 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932244AbcKPOJP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Nov 2016 09:09:15 -0500
Received: by mail-wm0-f65.google.com with SMTP id u144so11485748wmu.0
        for <netdev@vger.kernel.org>; Wed, 16 Nov 2016 06:09:15 -0800 (PST)
In-Reply-To: <1479305343-13167-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Make sure the device has a complete view of the FIB tables by invoking
their dump during module init.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/rocker/rocker_main.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/rocker/rocker_main.c b/drivers/net/ethernet/rocker/rocker_main.c
index b80ff12..6968473 100644
--- a/drivers/net/ethernet/rocker/rocker_main.c
+++ b/drivers/net/ethernet/rocker/rocker_main.c
@@ -2806,6 +2806,7 @@ static int rocker_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 
 	rocker->fib_nb.notifier_call = rocker_router_fib_event;
 	register_fib_notifier(&rocker->fib_nb);
+	fib_notifier_dump(&rocker->fib_nb);
 
 	dev_info(&pdev->dev, "Rocker switch with id %*phN\n",
 		 (int)sizeof(rocker->hw.id), &rocker->hw.id);
-- 
2.7.4
