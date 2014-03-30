From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net-next] qlcnic: Fix build failure due to undefined reference to `vxlan_get_rx_port'
Date: Sun, 30 Mar 2014 10:42:25 -0400
Message-ID: <1396190545-20241-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept-HSGLinuxNICDev@qlogic.com>,
	Shahed Shaikh <shahed.shaikh@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:17465 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752075AbaC3PTL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Mar 2014 11:19:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shahed Shaikh <shahed.shaikh@qlogic.com>

Commit 2b3d7b758c687("qlcnic: Add VXLAN Rx offload support") uses
vxlan_get_rx_port() which caused build failure when VXLAN=m.

This patch fixes the build failure by adding dependency on VXLAN
in Kconfig of qlcnic module and use vxlan_get_rx_port() accordingly.

Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
Hi David,

Please apply this patch to net-next.

Thanks,
Shahed
---
 drivers/net/ethernet/qlogic/Kconfig              |   10 ++++++++++
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |    2 ++
 2 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/Kconfig b/drivers/net/ethernet/qlogic/Kconfig
index f59e6be..c14bd31 100644
--- a/drivers/net/ethernet/qlogic/Kconfig
+++ b/drivers/net/ethernet/qlogic/Kconfig
@@ -56,6 +56,16 @@ config QLCNIC_DCB
 	  mode of DCB is supported. PG and PFC values are related only
 	  to Tx.
 
+config QLCNIC_VXLAN
+	bool "Virtual eXtensible Local Area Network (VXLAN) offload support"
+	default n
+	depends on QLCNIC && VXLAN && !(QLCNIC=y && VXLAN=m)
+	---help---
+	  This enables hardware offload support for VXLAN protocol over QLogic's
+	  84XX series adapters.
+	  Say Y here if you want to enable hardware offload support for
+	  Virtual eXtensible Local Area Network (VXLAN) in the driver.
+
 config QLGE
 	tristate "QLogic QLGE 10Gb Ethernet Driver Support"
 	depends on PCI
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 79be451..d341f65 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -1975,8 +1975,10 @@ qlcnic_attach(struct qlcnic_adapter *adapter)
 
 	qlcnic_create_sysfs_entries(adapter);
 
+#ifdef CONFIG_QLCNIC_VXLAN
 	if (qlcnic_encap_rx_offload(adapter))
 		vxlan_get_rx_port(netdev);
+#endif
 
 	adapter->is_up = QLCNIC_ADAPTER_UP_MAGIC;
 	return 0;
-- 
1.5.6
