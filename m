From: Jarod Wilson <jarod@redhat.com>
Subject: [PATCH 5/6] ethernet/qlcnic: advertise LRO support in vlan_features
Date: Thu, 13 Aug 2015 14:02:59 -0400
Message-ID: <1439488980-44738-6-git-send-email-jarod@redhat.com>
References: <1439488980-44738-1-git-send-email-jarod@redhat.com>
Cc: Jarod Wilson <jarod@redhat.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>,
	Dept-GELinuxNICDev@qlogic.com, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1439488980-44738-1-git-send-email-jarod@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Without this, the presence of a qlcnic device in a bond will not trigger
LRO support to be enabled at the bond level, even while it is enabled on
the slave itself.

This change becomes necessary when NETIF_F_LRO is added to
netdev_features.h's NETIF_F_ONE_FOR_ALL.

CC: Shahed Shaikh <shahed.shaikh@qlogic.com>
CC: Dept-GELinuxNICDev@qlogic.com
CC: netdev@vger.kernel.org
Signed-off-by: Jarod Wilson <jarod@redhat.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 8b08b20..5a798ab 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -2314,8 +2314,10 @@ qlcnic_setup_netdev(struct qlcnic_adapter *adapter, struct net_device *netdev,
 	if (qlcnic_sriov_vf_check(adapter))
 		netdev->features |= NETIF_F_HW_VLAN_CTAG_FILTER;
 
-	if (adapter->ahw->capabilities & QLCNIC_FW_CAPABILITY_HW_LRO)
+	if (adapter->ahw->capabilities & QLCNIC_FW_CAPABILITY_HW_LRO) {
 		netdev->features |= NETIF_F_LRO;
+		netdev->vlan_features |= NETIF_F_LRO;
+	}
 
 	if (qlcnic_encap_tx_offload(adapter)) {
 		netdev->features |= NETIF_F_GSO_UDP_TUNNEL;
-- 
1.8.3.1
