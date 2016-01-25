From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 1/2] i40e: fix build warnings
Date: Mon, 25 Jan 2016 15:58:51 -0800
Message-ID: <1453766332-43274-2-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1453766332-43274-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:32347 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755521AbcAYX7O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Jan 2016 18:59:14 -0500
In-Reply-To: <1453766332-43274-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Fixes following build warnings :

drivers/net/ethernet/intel/i40e/i40e_main.c:7057:13: warning:
'i40e_sync_udp_filters_subtask' defined but not used [-Wunused-function]
drivers/net/ethernet/intel/i40e/i40e_main.c:8524:13: warning:
'i40e_add_vxlan_port' defined but not used [-Wunused-function]
drivers/net/ethernet/intel/i40e/i40e_main.c:8569:13: warning:
'i40e_del_vxlan_port' defined but not used [-Wunused-function]
drivers/net/ethernet/intel/i40e/i40e_main.c:8604:13: warning:
'i40e_add_geneve_port' defined but not used [-Wunused-function]
drivers/net/ethernet/intel/i40e/i40e_main.c:8651:13: warning:
'i40e_del_geneve_port' defined but not used [-Wunused-function]

Fixes: 6a899024058d ("i40e: geneve tunnel offload support")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_main.c | 15 +++++----------
 1 file changed, 5 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c b/drivers/net/ethernet/intel/i40e/i40e_main.c
index bb4612c..8f3b53e 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_main.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
@@ -7117,9 +7117,7 @@ static void i40e_service_task(struct work_struct *work)
 	i40e_watchdog_subtask(pf);
 	i40e_fdir_reinit_subtask(pf);
 	i40e_sync_filters_subtask(pf);
-#if IS_ENABLED(CONFIG_VXLAN) || IS_ENABLED(CONFIG_GENEVE)
 	i40e_sync_udp_filters_subtask(pf);
-#endif
 	i40e_clean_adminq_subtask(pf);
 
 	i40e_service_event_complete(pf);
@@ -8515,6 +8513,8 @@ static u8 i40e_get_udp_port_idx(struct i40e_pf *pf, __be16 port)
 }
 
 #endif
+
+#if IS_ENABLED(CONFIG_VXLAN)
 /**
  * i40e_add_vxlan_port - Get notifications about VXLAN ports that come up
  * @netdev: This physical port's netdev
@@ -8524,7 +8524,6 @@ static u8 i40e_get_udp_port_idx(struct i40e_pf *pf, __be16 port)
 static void i40e_add_vxlan_port(struct net_device *netdev,
 				sa_family_t sa_family, __be16 port)
 {
-#if IS_ENABLED(CONFIG_VXLAN)
 	struct i40e_netdev_priv *np = netdev_priv(netdev);
 	struct i40e_vsi *vsi = np->vsi;
 	struct i40e_pf *pf = vsi->back;
@@ -8557,7 +8556,6 @@ static void i40e_add_vxlan_port(struct net_device *netdev,
 	pf->udp_ports[next_idx].type = I40E_AQC_TUNNEL_TYPE_VXLAN;
 	pf->pending_udp_bitmap |= BIT_ULL(next_idx);
 	pf->flags |= I40E_FLAG_UDP_FILTER_SYNC;
-#endif
 }
 
 /**
@@ -8569,7 +8567,6 @@ static void i40e_add_vxlan_port(struct net_device *netdev,
 static void i40e_del_vxlan_port(struct net_device *netdev,
 				sa_family_t sa_family, __be16 port)
 {
-#if IS_ENABLED(CONFIG_VXLAN)
 	struct i40e_netdev_priv *np = netdev_priv(netdev);
 	struct i40e_vsi *vsi = np->vsi;
 	struct i40e_pf *pf = vsi->back;
@@ -8592,9 +8589,10 @@ static void i40e_del_vxlan_port(struct net_device *netdev,
 		netdev_warn(netdev, "vxlan port %d was not found, not deleting\n",
 			    ntohs(port));
 	}
-#endif
 }
+#endif
 
+#if IS_ENABLED(CONFIG_GENEVE)
 /**
  * i40e_add_geneve_port - Get notifications about GENEVE ports that come up
  * @netdev: This physical port's netdev
@@ -8604,7 +8602,6 @@ static void i40e_del_vxlan_port(struct net_device *netdev,
 static void i40e_add_geneve_port(struct net_device *netdev,
 				 sa_family_t sa_family, __be16 port)
 {
-#if IS_ENABLED(CONFIG_GENEVE)
 	struct i40e_netdev_priv *np = netdev_priv(netdev);
 	struct i40e_vsi *vsi = np->vsi;
 	struct i40e_pf *pf = vsi->back;
@@ -8639,7 +8636,6 @@ static void i40e_add_geneve_port(struct net_device *netdev,
 	pf->flags |= I40E_FLAG_UDP_FILTER_SYNC;
 
 	dev_info(&pf->pdev->dev, "adding geneve port %d\n", ntohs(port));
-#endif
 }
 
 /**
@@ -8651,7 +8647,6 @@ static void i40e_add_geneve_port(struct net_device *netdev,
 static void i40e_del_geneve_port(struct net_device *netdev,
 				 sa_family_t sa_family, __be16 port)
 {
-#if IS_ENABLED(CONFIG_GENEVE)
 	struct i40e_netdev_priv *np = netdev_priv(netdev);
 	struct i40e_vsi *vsi = np->vsi;
 	struct i40e_pf *pf = vsi->back;
@@ -8677,8 +8672,8 @@ static void i40e_del_geneve_port(struct net_device *netdev,
 		netdev_warn(netdev, "geneve port %d was not found, not deleting\n",
 			    ntohs(port));
 	}
-#endif
 }
+#endif
 
 static int i40e_get_phys_port_id(struct net_device *netdev,
 				 struct netdev_phys_item_id *ppid)
-- 
2.5.0
