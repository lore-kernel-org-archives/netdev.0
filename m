From: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
Subject: [PATCH] i40e: fix build warnings
Date: Thu, 21 Jan 2016 14:01:51 +0000
Message-ID: <1453384911-20595-1-git-send-email-zhangshengju@cmss.chinamobile.com>
Cc: shannon.nelson@intel.com, carolyn.wyborny@intel.com,
	donald.c.skidmore@intel.com, bruce.w.allan@intel.com,
	john.ronciak@intel.com, mitch.a.williams@intel.com
To: jesse.brandeburg@intel.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmccmta3.chinamobile.com ([221.176.66.81]:8337 "EHLO
	cmccmta3.chinamobile.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759002AbcAUOBG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jan 2016 09:01:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

fix build warnings when CONFIG_VXLAN or CONFIG_GENEVE is not set.

$ make M=drivers/net/ethernet/intel/i40e C=2
  CHECK   drivers/net/ethernet/intel/i40e/i40e_main.c
  CC [M]  drivers/net/ethernet/intel/i40e/i40e_main.o
  drivers/net/ethernet/intel/i40e/i40e_main.c:8604:13: warning: 'i40e_add_geneve_port' defined but not used [-Wunused-function]
  drivers/net/ethernet/intel/i40e/i40e_main.c:8651:13: warning: 'i40e_del_geneve_port' defined but not used [-Wunused-function]

Signed-off-by: Zhang Shengju <zhangshengju@cmss.chinamobile.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 13 +++++--------
 1 file changed, 5 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index bb4612c..31e35f9 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -8515,6 +8515,8 @@ static u8 i40e_get_udp_port_idx(struct i40e_pf *pf, __be16 port)
 }
 
 #endif
+
+#if IS_ENABLED(CONFIG_VXLAN)
 /**
  * i40e_add_vxlan_port - Get notifications about VXLAN ports that come up
  * @netdev: This physical port's netdev
@@ -8524,7 +8526,6 @@ static u8 i40e_get_udp_port_idx(struct i40e_pf *pf, __be16 port)
 static void i40e_add_vxlan_port(struct net_device *netdev,
 				sa_family_t sa_family, __be16 port)
 {
-#if IS_ENABLED(CONFIG_VXLAN)
 	struct i40e_netdev_priv *np = netdev_priv(netdev);
 	struct i40e_vsi *vsi = np->vsi;
 	struct i40e_pf *pf = vsi->back;
@@ -8557,7 +8558,6 @@ static void i40e_add_vxlan_port(struct net_device *netdev,
 	pf->udp_ports[next_idx].type = I40E_AQC_TUNNEL_TYPE_VXLAN;
 	pf->pending_udp_bitmap |= BIT_ULL(next_idx);
 	pf->flags |= I40E_FLAG_UDP_FILTER_SYNC;
-#endif
 }
 
 /**
@@ -8569,7 +8569,6 @@ static void i40e_add_vxlan_port(struct net_device *netdev,
 static void i40e_del_vxlan_port(struct net_device *netdev,
 				sa_family_t sa_family, __be16 port)
 {
-#if IS_ENABLED(CONFIG_VXLAN)
 	struct i40e_netdev_priv *np = netdev_priv(netdev);
 	struct i40e_vsi *vsi = np->vsi;
 	struct i40e_pf *pf = vsi->back;
@@ -8592,9 +8591,10 @@ static void i40e_del_vxlan_port(struct net_device *netdev,
 		netdev_warn(netdev, "vxlan port %d was not found, not deleting\n",
 			    ntohs(port));
 	}
-#endif
 }
+#endif /* CONFIG_VXLAN */
 
+#if IS_ENABLED(CONFIG_GENEVE)
 /**
  * i40e_add_geneve_port - Get notifications about GENEVE ports that come up
  * @netdev: This physical port's netdev
@@ -8604,7 +8604,6 @@ static void i40e_del_vxlan_port(struct net_device *netdev,
 static void i40e_add_geneve_port(struct net_device *netdev,
 				 sa_family_t sa_family, __be16 port)
 {
-#if IS_ENABLED(CONFIG_GENEVE)
 	struct i40e_netdev_priv *np = netdev_priv(netdev);
 	struct i40e_vsi *vsi = np->vsi;
 	struct i40e_pf *pf = vsi->back;
@@ -8639,7 +8638,6 @@ static void i40e_add_geneve_port(struct net_device *netdev,
 	pf->flags |= I40E_FLAG_UDP_FILTER_SYNC;
 
 	dev_info(&pf->pdev->dev, "adding geneve port %d\n", ntohs(port));
-#endif
 }
 
 /**
@@ -8651,7 +8649,6 @@ static void i40e_add_geneve_port(struct net_device *netdev,
 static void i40e_del_geneve_port(struct net_device *netdev,
 				 sa_family_t sa_family, __be16 port)
 {
-#if IS_ENABLED(CONFIG_GENEVE)
 	struct i40e_netdev_priv *np = netdev_priv(netdev);
 	struct i40e_vsi *vsi = np->vsi;
 	struct i40e_pf *pf = vsi->back;
@@ -8677,8 +8674,8 @@ static void i40e_del_geneve_port(struct net_device *netdev,
 		netdev_warn(netdev, "geneve port %d was not found, not deleting\n",
 			    ntohs(port));
 	}
-#endif
 }
+#endif
 
 static int i40e_get_phys_port_id(struct net_device *netdev,
 				 struct netdev_phys_item_id *ppid)
-- 
1.8.3.1
