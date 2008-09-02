From: Ilya Yanok <yanok@emcraft.com>
Subject: tehuti: use resource_size_t instead of unsigned long and u32
Date: Wed,  3 Sep 2008 01:14:28 +0400
Message-ID: <1220390068-6433-1-git-send-email-yanok@emcraft.com>
Cc: wd@denx.de, dzu@denx.de, Ilya Yanok <yanok@emcraft.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ocean.emcraft.com ([213.221.7.182]:55759 "EHLO
	ocean.emcraft.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751633AbYIBWLs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2008 18:11:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use resource_size_t for pci_resource_start() and pci_resource_len() return
values. Makes tehuti driver work correctly on 32 bit systems with 64 bit
resources.

Signed-off-by: Ilya Yanok <yanok@emcraft.com>
---
 drivers/net/tehuti.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/tehuti.c b/drivers/net/tehuti.c
index 432e837..6e674a5 100644
--- a/drivers/net/tehuti.c
+++ b/drivers/net/tehuti.c
@@ -1909,8 +1909,7 @@ bdx_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	struct net_device *ndev;
 	struct bdx_priv *priv;
 	int err, pci_using_dac, port;
-	unsigned long pciaddr;
-	u32 regionSize;
+	resource_size_t pciaddr, regionSize;
 	struct pci_nic *nic;
 
 	ENTER;
@@ -1949,7 +1948,8 @@ bdx_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	}
 	if ((regionSize = pci_resource_len(pdev, 0)) < BDX_REGS_SIZE) {
 		err = -EIO;
-		ERR("tehuti: MMIO resource (%x) too small\n", regionSize);
+		ERR("tehuti: MMIO resource (%llx) too small\n",
+				(u64)regionSize);
 		goto err_out_res;
 	}
 
-- 
1.5.6.1

