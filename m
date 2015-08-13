From: Jarod Wilson <jarod@redhat.com>
Subject: [PATCH 6/6] ethernet/s2io: advertise what hw supports in vlan_features
Date: Thu, 13 Aug 2015 14:03:00 -0400
Message-ID: <1439488980-44738-7-git-send-email-jarod@redhat.com>
References: <1439488980-44738-1-git-send-email-jarod@redhat.com>
Cc: Jarod Wilson <jarod@redhat.com>, Jon Mason <jdmason@kudzu.us>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1439488980-44738-1-git-send-email-jarod@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

For some reason, the s2io driver has never filled in vlan_features. If
that's fully intentional, then this patch should be dropped. If its not,
then this patch is necessary to maintain some functionality of slave s2io
devices in a bonding group.

Without this, the presence of a s2io device in a bond will not trigger
LRO support to be enabled at the bond level, even while it is enabled on
the slave itself.

This change becomes necessary when NETIF_F_LRO is added to
netdev_features.h's NETIF_F_ONE_FOR_ALL.

CC: Jon Mason <jdmason@kudzu.us>
CC: netdev@vger.kernel.org
Signed-off-by: Jarod Wilson <jarod@redhat.com>
---
 drivers/net/ethernet/neterion/s2io.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/net/ethernet/neterion/s2io.c b/drivers/net/ethernet/neterion/s2io.c
index 2d1b942..8bbf540 100644
--- a/drivers/net/ethernet/neterion/s2io.c
+++ b/drivers/net/ethernet/neterion/s2io.c
@@ -7922,6 +7922,7 @@ s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)
 		NETIF_F_RXCSUM | NETIF_F_LRO;
 	dev->features |= dev->hw_features |
 		NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_CTAG_RX;
+	dev->vlan_features |= dev->hw_features;
 	if (sp->device_type & XFRAME_II_DEVICE) {
 		dev->hw_features |= NETIF_F_UFO;
 		if (ufo)
-- 
1.8.3.1
