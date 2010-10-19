From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH net-next] netxen: make local function static.
Date: Mon, 18 Oct 2010 20:40:10 -0700
Message-ID: <20101018204010.1dc01291@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Amit Kumar Salecha <amit.salecha@qlogic.com>,
	"David S. Miller" <davem@davemloft.net>,
	Narender Kumar <narender.kumar@qlogic.com>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:37745 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753430Ab0JSDkN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Oct 2010 23:40:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 drivers/net/netxen/netxen_nic.h      |   18 +-----------------
 drivers/net/netxen/netxen_nic_hw.c   |   29 +++++++++++------------------
 drivers/net/netxen/netxen_nic_main.c |    6 ++++--
 3 files changed, 16 insertions(+), 37 deletions(-)

--- a/drivers/net/netxen/netxen_nic_hw.c	2010-10-15 16:16:11.934234483 -0700
+++ b/drivers/net/netxen/netxen_nic_hw.c	2010-10-15 16:25:09.920752564 -0700
@@ -319,6 +319,8 @@ static unsigned crb_hub_agt[64] =
 
 #define NETXEN_PCIE_SEM_TIMEOUT	10000
 
+static int netxen_nic_set_mtu_xgb(struct netxen_adapter *adapter, int new_mtu);
+
 int
 netxen_pcie_sem_lock(struct netxen_adapter *adapter, int sem, u32 id_reg)
 {
@@ -345,7 +347,7 @@ netxen_pcie_sem_unlock(struct netxen_ada
 	NXRD32(adapter, NETXEN_PCIE_REG(PCIE_SEM_UNLOCK(sem)));
 }
 
-int netxen_niu_xg_init_port(struct netxen_adapter *adapter, int port)
+static int netxen_niu_xg_init_port(struct netxen_adapter *adapter, int port)
 {
 	if (NX_IS_REVISION_P2(adapter->ahw.revision_id)) {
 		NXWR32(adapter, NETXEN_NIU_XGE_CONFIG_1+(0x10000*port), 0x1447);
@@ -356,7 +358,7 @@ int netxen_niu_xg_init_port(struct netxe
 }
 
 /* Disable an XG interface */
-int netxen_niu_disable_xg_port(struct netxen_adapter *adapter)
+static int netxen_niu_disable_xg_port(struct netxen_adapter *adapter)
 {
 	__u32 mac_cfg;
 	u32 port = adapter->physical_port;
@@ -383,7 +385,7 @@ int netxen_niu_disable_xg_port(struct ne
 #define MAC_LO(addr) \
 	((addr[5] << 16) | (addr[4] << 8) | (addr[3]))
 
-int netxen_p2_nic_set_promisc(struct netxen_adapter *adapter, u32 mode)
+static int netxen_p2_nic_set_promisc(struct netxen_adapter *adapter, u32 mode)
 {
 	u32 mac_cfg;
 	u32 cnt = 0;
@@ -434,7 +436,7 @@ int netxen_p2_nic_set_promisc(struct net
 	return 0;
 }
 
-int netxen_p2_nic_set_mac_addr(struct netxen_adapter *adapter, u8 *addr)
+static int netxen_p2_nic_set_mac_addr(struct netxen_adapter *adapter, u8 *addr)
 {
 	u32 mac_hi, mac_lo;
 	u32 reg_hi, reg_lo;
@@ -531,7 +533,7 @@ netxen_nic_set_mcast_addr(struct netxen_
 	return 0;
 }
 
-void netxen_p2_nic_set_multi(struct net_device *netdev)
+static void netxen_p2_nic_set_multi(struct net_device *netdev)
 {
 	struct netxen_adapter *adapter = netdev_priv(netdev);
 	struct netdev_hw_addr *ha;
@@ -674,7 +676,7 @@ static int nx_p3_nic_add_mac(struct netx
 				cur->mac_addr, NETXEN_MAC_ADD);
 }
 
-void netxen_p3_nic_set_multi(struct net_device *netdev)
+static void netxen_p3_nic_set_multi(struct net_device *netdev)
 {
 	struct netxen_adapter *adapter = netdev_priv(netdev);
 	struct netdev_hw_addr *ha;
@@ -721,7 +723,7 @@ send_fw_cmd:
 	}
 }
 
-int netxen_p3_nic_set_promisc(struct netxen_adapter *adapter, u32 mode)
+static int netxen_p3_nic_set_promisc(struct netxen_adapter *adapter, u32 mode)
 {
 	nx_nic_req_t req;
 	u64 word;
@@ -754,7 +756,7 @@ void netxen_p3_free_mac_list(struct netx
 	}
 }
 
-int netxen_p3_nic_set_mac_addr(struct netxen_adapter *adapter, u8 *addr)
+static int netxen_p3_nic_set_mac_addr(struct netxen_adapter *adapter, u8 *addr)
 {
 	/* assuming caller has already copied new addr to netdev */
 	netxen_p3_nic_set_multi(adapter->netdev);
@@ -1867,16 +1869,7 @@ int netxen_nic_get_board_info(struct net
 }
 
 /* NIU access sections */
-
-int netxen_nic_set_mtu_gb(struct netxen_adapter *adapter, int new_mtu)
-{
-	new_mtu += MTU_FUDGE_FACTOR;
-	NXWR32(adapter, NETXEN_NIU_GB_MAX_FRAME_SIZE(adapter->physical_port),
-		new_mtu);
-	return 0;
-}
-
-int netxen_nic_set_mtu_xgb(struct netxen_adapter *adapter, int new_mtu)
+static int netxen_nic_set_mtu_xgb(struct netxen_adapter *adapter, int new_mtu)
 {
 	new_mtu += MTU_FUDGE_FACTOR;
 	if (adapter->physical_port == 0)
--- a/drivers/net/netxen/netxen_nic_main.c	2010-10-15 16:18:10.750321685 -0700
+++ b/drivers/net/netxen/netxen_nic_main.c	2010-10-15 16:21:45.277705058 -0700
@@ -95,6 +95,8 @@ static irqreturn_t netxen_msi_intr(int i
 static irqreturn_t netxen_msix_intr(int irq, void *data);
 
 static void netxen_config_indev_addr(struct net_device *dev, unsigned long);
+static struct net_device_stats *netxen_nic_get_stats(struct net_device *netdev);
+static int netxen_nic_set_mac(struct net_device *netdev, void *p);
 
 /*  PCI Device ID Table  */
 #define ENTRY(device) \
@@ -460,7 +462,7 @@ netxen_read_mac_addr(struct netxen_adapt
 	return 0;
 }
 
-int netxen_nic_set_mac(struct net_device *netdev, void *p)
+static int netxen_nic_set_mac(struct net_device *netdev, void *p)
 {
 	struct netxen_adapter *adapter = netdev_priv(netdev);
 	struct sockaddr *addr = p;
@@ -2027,7 +2029,7 @@ request_reset:
 	clear_bit(__NX_RESETTING, &adapter->state);
 }
 
-struct net_device_stats *netxen_nic_get_stats(struct net_device *netdev)
+static struct net_device_stats *netxen_nic_get_stats(struct net_device *netdev)
 {
 	struct netxen_adapter *adapter = netdev_priv(netdev);
 	struct net_device_stats *stats = &netdev->stats;
--- a/drivers/net/netxen/netxen_nic.h	2010-10-15 16:16:06.350042428 -0700
+++ b/drivers/net/netxen/netxen_nic.h	2010-10-15 16:22:27.963174722 -0700
@@ -1253,19 +1253,9 @@ struct netxen_adapter {
 	const struct firmware *fw;
 };
 
-int netxen_niu_xg_init_port(struct netxen_adapter *adapter, int port);
-int netxen_niu_disable_xg_port(struct netxen_adapter *adapter);
-
 int nx_fw_cmd_query_phy(struct netxen_adapter *adapter, u32 reg, u32 *val);
 int nx_fw_cmd_set_phy(struct netxen_adapter *adapter, u32 reg, u32 val);
 
-/* Functions available from netxen_nic_hw.c */
-int netxen_nic_set_mtu_xgb(struct netxen_adapter *adapter, int new_mtu);
-int netxen_nic_set_mtu_gb(struct netxen_adapter *adapter, int new_mtu);
-
-int netxen_p2_nic_set_mac_addr(struct netxen_adapter *adapter, u8 *addr);
-int netxen_p3_nic_set_mac_addr(struct netxen_adapter *adapter, u8 *addr);
-
 #define NXRD32(adapter, off) \
 	(adapter->crb_read(adapter, off))
 #define NXWR32(adapter, off, val) \
@@ -1345,11 +1335,8 @@ void netxen_post_rx_buffers(struct netxe
 		struct nx_host_rds_ring *rds_ring);
 int netxen_process_cmd_ring(struct netxen_adapter *adapter);
 int netxen_process_rcv_ring(struct nx_host_sds_ring *sds_ring, int max);
-void netxen_p2_nic_set_multi(struct net_device *netdev);
-void netxen_p3_nic_set_multi(struct net_device *netdev);
+
 void netxen_p3_free_mac_list(struct netxen_adapter *adapter);
-int netxen_p2_nic_set_promisc(struct netxen_adapter *adapter, u32 mode);
-int netxen_p3_nic_set_promisc(struct netxen_adapter *adapter, u32);
 int netxen_config_intr_coalesce(struct netxen_adapter *adapter);
 int netxen_config_rss(struct netxen_adapter *adapter, int enable);
 int netxen_config_ipaddr(struct netxen_adapter *adapter, u32 ip, int cmd);
@@ -1364,9 +1351,6 @@ int netxen_config_hw_lro(struct netxen_a
 int netxen_config_bridged_mode(struct netxen_adapter *adapter, int enable);
 int netxen_send_lro_cleanup(struct netxen_adapter *adapter);
 
-int netxen_nic_set_mac(struct net_device *netdev, void *p);
-struct net_device_stats *netxen_nic_get_stats(struct net_device *netdev);
-
 void netxen_nic_update_cmd_producer(struct netxen_adapter *adapter,
 		struct nx_host_tx_ring *tx_ring);
 
