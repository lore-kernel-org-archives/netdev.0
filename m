From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 1/4] netxen: fix endianness read mac address
Date: Thu, 14 Jan 2010 03:53:21 -0800
Message-ID: <1263470004-30008-2-git-send-email-amit.salecha@qlogic.com>
References: <1263470004-30008-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, dhananjay.phadke@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:60075 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1755288Ab0ANLxZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Jan 2010 06:53:25 -0500
In-Reply-To: <1263470004-30008-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In netxen_read_mac_addr, mac_addr should be declared
u64 instead of __le64, used by host only.

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/netxen/netxen_nic.h      |    4 ++--
 drivers/net/netxen/netxen_nic_hw.c   |    4 ++--
 drivers/net/netxen/netxen_nic_main.c |    2 +-
 3 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 8264ae0..1e9c8fa 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -1427,8 +1427,8 @@ static inline u32 netxen_tx_avail(struct nx_host_tx_ring *tx_ring)
 
 }
 
-int netxen_get_flash_mac_addr(struct netxen_adapter *adapter, __le64 *mac);
-int netxen_p3_get_mac_addr(struct netxen_adapter *adapter, __le64 *mac);
+int netxen_get_flash_mac_addr(struct netxen_adapter *adapter, u64 *mac);
+int netxen_p3_get_mac_addr(struct netxen_adapter *adapter, u64 *mac);
 extern void netxen_change_ringparam(struct netxen_adapter *adapter);
 extern int netxen_rom_fast_read(struct netxen_adapter *adapter, int addr,
 				int *valp);
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index 85e28e6..0db36f1 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -1033,7 +1033,7 @@ static int netxen_get_flash_block(struct netxen_adapter *adapter, int base,
 	return 0;
 }
 
-int netxen_get_flash_mac_addr(struct netxen_adapter *adapter, __le64 *mac)
+int netxen_get_flash_mac_addr(struct netxen_adapter *adapter, u64 *mac)
 {
 	__le32 *pmac = (__le32 *) mac;
 	u32 offset;
@@ -1058,7 +1058,7 @@ int netxen_get_flash_mac_addr(struct netxen_adapter *adapter, __le64 *mac)
 	return 0;
 }
 
-int netxen_p3_get_mac_addr(struct netxen_adapter *adapter, __le64 *mac)
+int netxen_p3_get_mac_addr(struct netxen_adapter *adapter, u64 *mac)
 {
 	uint32_t crbaddr, mac_hi, mac_lo;
 	int pci_func = adapter->ahw.pci_func;
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index def4a07..b69cb3c 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -432,7 +432,7 @@ netxen_read_mac_addr(struct netxen_adapter *adapter)
 {
 	int i;
 	unsigned char *p;
-	__le64 mac_addr;
+	u64 mac_addr;
 	struct net_device *netdev = adapter->netdev;
 	struct pci_dev *pdev = adapter->pdev;
 
-- 
1.6.0.2

