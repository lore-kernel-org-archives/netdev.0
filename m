From: Jarod Wilson <jarod@redhat.com>
Subject: [PATCH 4/6] ethernet/netxen: advertise LRO support in vlan_features
Date: Thu, 13 Aug 2015 14:02:58 -0400
Message-ID: <1439488980-44738-5-git-send-email-jarod@redhat.com>
References: <1439488980-44738-1-git-send-email-jarod@redhat.com>
Cc: Jarod Wilson <jarod@redhat.com>,
	Manish Chopra <manish.chopra@qlogic.com>,
	Sony Chacko <sony.chacko@qlogic.com>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1439488980-44738-1-git-send-email-jarod@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Without this, the presence of a netxen device in a bond will not trigger
LRO support to be enabled at the bond level, even while it is enabled on
the slave itself.

This change becomes necessary when NETIF_F_LRO is added to
netdev_features.h's NETIF_F_ONE_FOR_ALL.

CC: Manish Chopra <manish.chopra@qlogic.com>
CC: Sony Chacko <sony.chacko@qlogic.com>
CC: Rajesh Borundia <rajesh.borundia@qlogic.com>
CC: netdev@vger.kernel.org
Signed-off-by: Jarod Wilson <jarod@redhat.com>
---
 drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
index 6409a06..0fd5ada54 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
@@ -1387,8 +1387,10 @@ netxen_setup_netdev(struct netxen_adapter *adapter,
 	if (adapter->capabilities & NX_FW_CAPABILITY_FVLANTX)
 		netdev->hw_features |= NETIF_F_HW_VLAN_CTAG_TX;
 
-	if (adapter->capabilities & NX_FW_CAPABILITY_HW_LRO)
+	if (adapter->capabilities & NX_FW_CAPABILITY_HW_LRO) {
 		netdev->hw_features |= NETIF_F_LRO;
+		netdev->vlan_features |= NETIF_F_LRO;
+	}
 
 	netdev->features |= netdev->hw_features;
 
-- 
1.8.3.1
