From: Jarod Wilson <jarod@redhat.com>
Subject: [PATCH 2/6] ethernet/bnx2x: advertise LRO support in vlan_features
Date: Thu, 13 Aug 2015 14:02:56 -0400
Message-ID: <1439488980-44738-3-git-send-email-jarod@redhat.com>
References: <1439488980-44738-1-git-send-email-jarod@redhat.com>
Cc: Jarod Wilson <jarod@redhat.com>,
	Ariel Elior <ariel.elior@qlogic.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1439488980-44738-1-git-send-email-jarod@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Without this, the presence of a bnx2x device in a bond will not trigger
LRO support to be enabled at the bond level, even while it is enabled on
the slave itself.

This change becomes necessary when NETIF_F_LRO is added to
netdev_features.h's NETIF_F_ONE_FOR_ALL.

CC: Ariel Elior <ariel.elior@qlogic.com>
CC: netdev@vger.kernel.org
Signed-off-by: Jarod Wilson <jarod@redhat.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index ad73a60..41dc066 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -13083,7 +13083,8 @@ static int bnx2x_init_dev(struct bnx2x *bp, struct pci_dev *pdev,
 	}
 
 	dev->vlan_features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
-		NETIF_F_TSO | NETIF_F_TSO_ECN | NETIF_F_TSO6 | NETIF_F_HIGHDMA;
+		NETIF_F_TSO | NETIF_F_TSO_ECN | NETIF_F_TSO6 | NETIF_F_HIGHDMA |
+		NETIF_F_LRO;
 
 	/* VF with OLD Hypervisor or old PF do not support filtering */
 	if (IS_PF(bp)) {
-- 
1.8.3.1
