From: Tobias Regnery <tobias.regnery@gmail.com>
Subject: [PATCH net-next] alx: add feature flag for rx checksumming
Date: Mon,  9 Jan 2017 13:15:55 +0100
Message-ID: <20170109121555.4592-1-tobias.regnery@gmail.com>
Cc: davem@davemloft.net, Tobias Regnery <tobias.regnery@gmail.com>
To: netdev@vger.kernel.org, jcliburn@gmail.com, chris.snook@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34738 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1760237AbdAIMQQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 07:16:16 -0500
Received: by mail-wm0-f68.google.com with SMTP id c85so21543083wmi.1
        for <netdev@vger.kernel.org>; Mon, 09 Jan 2017 04:16:16 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The code to handle rx checksumming was in the driver since its introduction
but for reasons unknown the feature flag was left out. Now it is possible
to enable this feature with ethtool.

Tested on my AR8161 ethernet card, there are no regressions observed in
netperf if this feature is enabled.

Signed-off-by: Tobias Regnery <tobias.regnery@gmail.com>
---
 drivers/net/ethernet/atheros/alx/main.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/atheros/alx/main.c b/drivers/net/ethernet/atheros/alx/main.c
index c66195d00ed4..4c80e0689db9 100644
--- a/drivers/net/ethernet/atheros/alx/main.c
+++ b/drivers/net/ethernet/atheros/alx/main.c
@@ -1816,6 +1816,7 @@ static int alx_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	netdev->hw_features = NETIF_F_SG |
 			      NETIF_F_HW_CSUM |
+			      NETIF_F_RXCSUM |
 			      NETIF_F_TSO |
 			      NETIF_F_TSO6;
 
-- 
2.9.3
