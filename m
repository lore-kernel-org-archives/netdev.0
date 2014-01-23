From: Himanshu Madhani <himanshu.madhani@qlogic.com>
Subject: [PATCH net-next 1/7] qlcnic: Use bool for rx_mac_learn.
Date: Thu, 23 Jan 2014 17:18:28 -0500
Message-ID: <eae4e19d3ffc344f833f2afe7a67217d9d2e6893.1390491376.git.himanshu.madhani@qlogic.com>
References: <cover.1390491376.git.himanshu.madhani@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>,
	<himanshu.madhani@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:45906 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755623AbaAWWwx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jan 2014 17:52:53 -0500
In-Reply-To: <cover.1390491376.git.himanshu.madhani@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>

o Use boolean type instead of u8.

Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Signed-off-by: Himanshu Madhani <himanshu.madhani@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h           | 2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c   | 2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c | 2 +-
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_vnic.c | 4 ++--
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c        | 4 ++--
 5 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index 69a6ca0..c85cb84 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -1082,7 +1082,7 @@ struct qlcnic_adapter {
 	u64 dev_rst_time;
 	bool drv_mac_learn;
 	bool fdb_mac_learn;
-	u8 rx_mac_learn;
+	bool rx_mac_learn;
 	unsigned long vlans[BITS_TO_LONGS(VLAN_N_VID)];
 	u8 flash_mfg_id;
 	struct qlcnic_npar_info *npars;
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
index 2949845..b66b199 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_hw.c
@@ -1637,7 +1637,7 @@ static void qlcnic_83xx_set_interface_id_promisc(struct qlcnic_adapter *adapter,
 	if (qlcnic_sriov_pf_check(adapter)) {
 		qlcnic_alloc_lb_filters_mem(adapter);
 		qlcnic_pf_set_interface_id_promisc(adapter, interface_id);
-		adapter->rx_mac_learn = 1;
+		adapter->rx_mac_learn = true;
 	} else {
 		if (!qlcnic_sriov_vf_check(adapter))
 			*interface_id = adapter->recv_ctx->context_id << 16;
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
index 6d7f6a1..f19cec8 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_init.c
@@ -2217,7 +2217,7 @@ int qlcnic_83xx_init(struct qlcnic_adapter *adapter, int pci_using_dac)
 	struct qlcnic_hardware_context *ahw = adapter->ahw;
 	int err = 0;
 
-	adapter->rx_mac_learn = 0;
+	adapter->rx_mac_learn = false;
 	ahw->msix_supported = !!qlcnic_use_msi_x;
 
 	qlcnic_83xx_init_rings(adapter);
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_vnic.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_vnic.c
index e26c49f..be7d7a6 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_vnic.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_83xx_vnic.c
@@ -227,10 +227,10 @@ int qlcnic_83xx_config_vnic_opmode(struct qlcnic_adapter *adapter)
 	if (ahw->capabilities & QLC_83XX_ESWITCH_CAPABILITY) {
 		adapter->flags |= QLCNIC_ESWITCH_ENABLED;
 		if (adapter->drv_mac_learn)
-			adapter->rx_mac_learn = 1;
+			adapter->rx_mac_learn = true;
 	} else {
 		adapter->flags &= ~QLCNIC_ESWITCH_ENABLED;
-		adapter->rx_mac_learn = 0;
+		adapter->rx_mac_learn = false;
 	}
 
 	ahw->idc.vnic_state = QLCNIC_DEV_NPAR_NON_OPER;
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
index e861479..d012e83 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_hw.c
@@ -547,10 +547,10 @@ static void __qlcnic_set_multi(struct net_device *netdev, u16 vlan)
 		qlcnic_alloc_lb_filters_mem(adapter);
 		adapter->drv_mac_learn = 1;
 		if (adapter->flags & QLCNIC_ESWITCH_ENABLED)
-			adapter->rx_mac_learn = 1;
+			adapter->rx_mac_learn = true;
 	} else {
 		adapter->drv_mac_learn = 0;
-		adapter->rx_mac_learn = 0;
+		adapter->rx_mac_learn = false;
 	}
 
 	qlcnic_nic_set_promisc(adapter, mode);
-- 
1.8.1.4
