From: Netanel Belgazal <netanel@annapurnalabs.com>
Subject: [PATCH V3 net-next 02/14] net/ena: fix error handling when probe fails
Date: Fri, 27 Jan 2017 00:18:04 +0200
Message-ID: <1485469096-5271-3-git-send-email-netanel@annapurnalabs.com>
References: <1485469096-5271-1-git-send-email-netanel@annapurnalabs.com>
Cc: Netanel Belgazal <netanel@annapurnalabs.com>, dwmw@amazon.com,
        zorik@annapurnalabs.com, alex@annapurnalabs.com,
        saeed@annapurnalabs.com, msw@amazon.com, aliguori@amazon.com,
        nafea@annapurnalabs.com, eric.dumazet@gmail.com
To: linux-kernel@vger.kernel.org, davem@davemloft.net,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1485469096-5271-1-git-send-email-netanel@annapurnalabs.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When driver fails in probe, it will release all resources,
including adapter.
In case of probe failure, ena_remove should not try to
free the adapter resources.

Signed-off-by: Netanel Belgazal <netanel@annapurnalabs.com>
---
 drivers/net/ethernet/amazon/ena/ena_netdev.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/amazon/ena/ena_netdev.c b/drivers/net/ethernet/amazon/ena/ena_netdev.c
index 7493ea3..cb60567 100644
--- a/drivers/net/ethernet/amazon/ena/ena_netdev.c
+++ b/drivers/net/ethernet/amazon/ena/ena_netdev.c
@@ -3046,6 +3046,7 @@ static int ena_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 err_free_region:
 	ena_release_bars(ena_dev, pdev);
 err_free_ena_dev:
+	pci_set_drvdata(pdev, NULL);
 	vfree(ena_dev);
 err_disable_device:
 	pci_disable_device(pdev);
-- 
2.7.4
