From: Netanel Belgazal <netanel@annapurnalabs.com>
Subject: [PATCH net 16/18] net/ena: fix error handling when probe fails
Date: Sun, 20 Nov 2016 10:45:45 +0200
Message-ID: <1479631547-29354-17-git-send-email-netanel@annapurnalabs.com>
References: <1479631547-29354-1-git-send-email-netanel@annapurnalabs.com>
Cc: Netanel Belgazal <netanel@annapurnalabs.com>, dwmw@amazon.com,
        zorik@annapurnalabs.com, alex@annapurnalabs.com,
        saeed@annapurnalabs.com, msw@amazon.com, aliguori@amazon.com,
        nafea@annapurnalabs.com
To: linux-kernel@vger.kernel.org, davem@davemloft.net,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:35440 "EHLO
        mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753554AbcKTIqg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 20 Nov 2016 03:46:36 -0500
Received: by mail-wm0-f45.google.com with SMTP id a197so100047793wmd.0
        for <netdev@vger.kernel.org>; Sun, 20 Nov 2016 00:46:35 -0800 (PST)
In-Reply-To: <1479631547-29354-1-git-send-email-netanel@annapurnalabs.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When driver fails in probe, it will release all resources, including
adapter.
In case of probe failure, ena_remove should not try to free the adapter
resources.

Signed-off-by: Netanel Belgazal <netanel@annapurnalabs.com>
---
 drivers/net/ethernet/amazon/ena/ena_netdev.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/amazon/ena/ena_netdev.c b/drivers/net/ethernet/amazon/ena/ena_netdev.c
index bff082a..ba395aa 100644
--- a/drivers/net/ethernet/amazon/ena/ena_netdev.c
+++ b/drivers/net/ethernet/amazon/ena/ena_netdev.c
@@ -3179,6 +3179,7 @@ static int ena_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 err_free_region:
 	ena_release_bars(ena_dev, pdev);
 err_free_ena_dev:
+	pci_set_drvdata(pdev, NULL);
 	vfree(ena_dev);
 err_disable_device:
 	pci_disable_device(pdev);
-- 
1.9.1
