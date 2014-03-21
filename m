From: Wang Weidong <wangweidong1@huawei.com>
Subject: [PATCH net-next v2] atheros/atlx: use SET_ETHTOOL_OPS directly
Date: Fri, 21 Mar 2014 09:50:43 +0800
Message-ID: <532B9AF3.8080301@huawei.com>
References: <532965C3.6090706@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>, <jcliburn@gmail.com>,
	<chris.snook@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:47765 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933422AbaCUBwB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2014 21:52:01 -0400
In-Reply-To: <532965C3.6090706@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As commit a6e28b34205b("staging/et131x: use SET_ETHTOOL_OPS
directly"), using a wrapper around SET_ETHTOOL_OPS macro is
not actually required, remove and use SET_ETHTOOL_OPS directly.

Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
---
Change note: 

v2: fix the build error.

---
 drivers/net/ethernet/atheros/atlx/atl2.c | 10 ++--------
 1 file changed, 2 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/atheros/atlx/atl2.c b/drivers/net/ethernet/atheros/atlx/atl2.c
index 265ce1b..78befb5 100644
--- a/drivers/net/ethernet/atheros/atlx/atl2.c
+++ b/drivers/net/ethernet/atheros/atlx/atl2.c
@@ -55,6 +55,7 @@ static const char atl2_driver_name[] = "atl2";
 static const char atl2_driver_string[] = "Atheros(R) L2 Ethernet Driver";
 static const char atl2_copyright[] = "Copyright (c) 2007 Atheros Corporation.";
 static const char atl2_driver_version[] = ATL2_DRV_VERSION;
+static const struct ethtool_ops atl2_ethtool_ops;
 
 MODULE_AUTHOR("Atheros Corporation <xiong.huang@atheros.com>, Chris Snook <csnook@redhat.com>");
 MODULE_DESCRIPTION("Atheros Fast Ethernet Network Driver");
@@ -71,8 +72,6 @@ static DEFINE_PCI_DEVICE_TABLE(atl2_pci_tbl) = {
 };
 MODULE_DEVICE_TABLE(pci, atl2_pci_tbl);
 
-static void atl2_set_ethtool_ops(struct net_device *netdev);
-
 static void atl2_check_options(struct atl2_adapter *adapter);
 
 /**
@@ -1397,7 +1396,7 @@ static int atl2_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	atl2_setup_pcicmd(pdev);
 
 	netdev->netdev_ops = &atl2_netdev_ops;
-	atl2_set_ethtool_ops(netdev);
+	SET_ETHTOOL_OPS(netdev, &atl2_ethtool_ops);
 	netdev->watchdog_timeo = 5 * HZ;
 	strncpy(netdev->name, pci_name(pdev), sizeof(netdev->name) - 1);
 
@@ -2105,11 +2104,6 @@ static const struct ethtool_ops atl2_ethtool_ops = {
 	.set_eeprom		= atl2_set_eeprom,
 };
 
-static void atl2_set_ethtool_ops(struct net_device *netdev)
-{
-	SET_ETHTOOL_OPS(netdev, &atl2_ethtool_ops);
-}
-
 #define LBYTESWAP(a)  ((((a) & 0x00ff00ff) << 8) | \
 	(((a) & 0xff00ff00) >> 8))
 #define LONGSWAP(a)   ((LBYTESWAP(a) << 16) | (LBYTESWAP(a) >> 16))
-- 
1.7.12
