From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH net-2.6 2/4] netxen: fix smatch warning
Date: Fri,  8 Jan 2010 00:10:15 -0800
Message-ID: <1262938217-10089-3-git-send-email-amit.salecha@qlogic.com>
References: <1262938217-10089-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, dhananjay.phadke@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:25992 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1753241Ab0AHIKV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Jan 2010 03:10:21 -0500
In-Reply-To: <1262938217-10089-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o Fix pointless assignments

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/netxen/netxen_nic_hw.c   |    3 +--
 drivers/net/netxen/netxen_nic_init.c |    2 +-
 drivers/net/netxen/netxen_nic_main.c |    2 +-
 3 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index 2e364fe..398dfd4 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -345,8 +345,7 @@ netxen_pcie_sem_lock(struct netxen_adapter *adapter, int sem, u32 id_reg)
 void
 netxen_pcie_sem_unlock(struct netxen_adapter *adapter, int sem)
 {
-	int val;
-	val = NXRD32(adapter, NETXEN_PCIE_REG(PCIE_SEM_UNLOCK(sem)));
+	NXRD32(adapter, NETXEN_PCIE_REG(PCIE_SEM_UNLOCK(sem)));
 }
 
 int netxen_niu_xg_init_port(struct netxen_adapter *adapter, int port)
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index 925b699..64cff68 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -784,7 +784,7 @@ netxen_need_fw_reset(struct netxen_adapter *adapter)
 	if (NXRD32(adapter, CRB_CMDPEG_STATE) == PHAN_INITIALIZE_FAILED)
 		return 1;
 
-	old_count = count = NXRD32(adapter, NETXEN_PEG_ALIVE_COUNTER);
+	old_count = NXRD32(adapter, NETXEN_PEG_ALIVE_COUNTER);
 
 	for (i = 0; i < 10; i++) {
 
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 880fcd0..9f9d608 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -340,7 +340,7 @@ netxen_check_hw_init(struct netxen_adapter *adapter, int first_boot)
 		if (!(first_boot & 0x4)) {
 			first_boot |= 0x4;
 			NXWR32(adapter, NETXEN_PCIE_REG(0x4), first_boot);
-			first_boot = NXRD32(adapter, NETXEN_PCIE_REG(0x4));
+			NXRD32(adapter, NETXEN_PCIE_REG(0x4));
 		}
 
 		/* This is the first boot after power up */
-- 
1.6.0.2

