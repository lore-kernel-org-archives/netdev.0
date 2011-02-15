From: Ivan Vecera <ivecera@redhat.com>
Subject: [PATCH] drivers/net: Call netif_carrier_off at the end of the probe
Date: Tue, 15 Feb 2011 13:08:39 +0100
Message-ID: <1297771719-14202-1-git-send-email-ivecera@redhat.com>
Cc: romieu@fr.zoreil.com, davem@davemloft.net, aabdulla@nvidia.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:20726 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753921Ab1BOMIw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Feb 2011 07:08:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Without calling of netif_carrier_off at the end of the probe the operstate
is unknown when the device is initially opened. By default the carrier is
on so when the device is opened and netif_carrier_on is called the link
watch event is not fired and operstate remains zero (unknown).

This patch fixes this behavior in forcedeth and r8169.

Signed-off-by: Ivan Vecera <ivecera@redhat.com>
---
 drivers/net/forcedeth.c |    2 ++
 drivers/net/r8169.c     |    2 ++
 2 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index af09296..9c0b1ba 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -5645,6 +5645,8 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 		goto out_error;
 	}
 
+	netif_carrier_off(dev);
+
 	dev_info(&pci_dev->dev, "ifname %s, PHY OUI 0x%x @ %d, addr %pM\n",
 		 dev->name, np->phy_oui, np->phyaddr, dev->dev_addr);
 
diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 59ccf0c..469ab0b 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -3190,6 +3190,8 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (pci_dev_run_wake(pdev))
 		pm_runtime_put_noidle(&pdev->dev);
 
+	netif_carrier_off(dev);
+
 out:
 	return rc;
 
-- 
1.7.3.4

