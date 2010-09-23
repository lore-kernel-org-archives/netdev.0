From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH] e1000/e1000e/igb/ixgb/ixgbe: set NETIF_F_HIGHDMA
	for VLAN feature flags
Date: Wed, 22 Sep 2010 20:57:58 -0700
Message-ID: <20100923035755.11561.14170.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Yi Zou <yi.zou@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta08.westchester.pa.mail.comcast.net ([76.96.62.80]:42823
	"EHLO qmta08.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752600Ab0IWD6T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Sep 2010 23:58:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yi Zou <yi.zou@intel.com>

If the netdev->features is set with NETIF_F_HIGHDMA, we should set the
corresponding netdev->vlan_features as well to allow VLAN netdev created
on top of the real netdev to be able to also benefit from HIGHDMA on 32bit
system, reducing the performance hit that is caused by __skb_linearize(),
particularly for large send. This is fixed in this patch for all Intel e1000,
e1000e, igb, ixgbe, and ixgbe drivers since this should be beneficial
to all devices supported by these drivers.

Signed-off-by: Yi Zou <yi.zou@intel.com>
Tested-by: Emil Tantilov <emil.s.tantilov@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000/e1000_main.c |    4 +++-
 drivers/net/e1000e/netdev.c    |    4 +++-
 drivers/net/igb/igb_main.c     |    4 +++-
 drivers/net/ixgb/ixgb_main.c   |    4 +++-
 drivers/net/ixgbe/ixgbe_main.c |    4 +++-
 5 files changed, 15 insertions(+), 5 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 8d9269d..a1dacea 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -988,8 +988,10 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	   (hw->mac_type != e1000_82547))
 		netdev->features |= NETIF_F_TSO;
 
-	if (pci_using_dac)
+	if (pci_using_dac) {
 		netdev->features |= NETIF_F_HIGHDMA;
+		netdev->vlan_features |= NETIF_F_HIGHDMA;
+	}
 
 	netdev->vlan_features |= NETIF_F_TSO;
 	netdev->vlan_features |= NETIF_F_HW_CSUM;
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index e2c7e0d..4630bad 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -5683,8 +5683,10 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	netdev->vlan_features |= NETIF_F_HW_CSUM;
 	netdev->vlan_features |= NETIF_F_SG;
 
-	if (pci_using_dac)
+	if (pci_using_dac) {
 		netdev->features |= NETIF_F_HIGHDMA;
+		netdev->vlan_features |= NETIF_F_HIGHDMA;
+	}
 
 	if (e1000e_enable_mng_pass_thru(&adapter->hw))
 		adapter->flags |= FLAG_MNG_PT_ENABLED;
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 61892b8..f915e9c 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -1858,8 +1858,10 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 	netdev->vlan_features |= NETIF_F_IPV6_CSUM;
 	netdev->vlan_features |= NETIF_F_SG;
 
-	if (pci_using_dac)
+	if (pci_using_dac) {
 		netdev->features |= NETIF_F_HIGHDMA;
+		netdev->vlan_features |= NETIF_F_HIGHDMA;
+	}
 
 	if (hw->mac.type >= e1000_82576)
 		netdev->features |= NETIF_F_SCTP_CSUM;
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index c2f6e71..80e6257 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -446,8 +446,10 @@ ixgb_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 			   NETIF_F_HW_VLAN_FILTER;
 	netdev->features |= NETIF_F_TSO;
 
-	if (pci_using_dac)
+	if (pci_using_dac) {
 		netdev->features |= NETIF_F_HIGHDMA;
+		netdev->vlan_features |= NETIF_F_HIGHDMA;
+	}
 
 	/* make sure the EEPROM is good */
 
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index d03eef9..0ec4ef2 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -6842,8 +6842,10 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 		netdev->vlan_features |= NETIF_F_FCOE_MTU;
 	}
 #endif /* IXGBE_FCOE */
-	if (pci_using_dac)
+	if (pci_using_dac) {
 		netdev->features |= NETIF_F_HIGHDMA;
+		netdev->vlan_features |= NETIF_F_HIGHDMA;
+	}
 
 	if (adapter->flags2 & IXGBE_FLAG2_RSC_ENABLED)
 		netdev->features |= NETIF_F_LRO;

