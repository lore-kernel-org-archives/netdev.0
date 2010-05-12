From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 1/4] netxen: fix register usage
Date: Wed, 12 May 2010 02:53:02 -0700
Message-ID: <1273657985-13405-2-git-send-email-amit.salecha@qlogic.com>
References: <1273657985-13405-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:45954 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1755330Ab0ELJxI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 May 2010 05:53:08 -0400
In-Reply-To: <1273657985-13405-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o For NX3031, MSI_MODE, CAPABILITIES_FW and SCRATCHPAD registers
  are obsolete. These register addresses can be used for different
  purpose.

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/netxen/netxen_nic_ethtool.c |    3 +++
 drivers/net/netxen/netxen_nic_hdr.h     |    2 --
 drivers/net/netxen/netxen_nic_init.c    |    4 +++-
 3 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_ethtool.c b/drivers/net/netxen/netxen_nic_ethtool.c
index aecba78..20f7c58 100644
--- a/drivers/net/netxen/netxen_nic_ethtool.c
+++ b/drivers/net/netxen/netxen_nic_ethtool.c
@@ -632,6 +632,9 @@ static int netxen_nic_reg_test(struct net_device *dev)
 	if ((data_read & 0xffff) != adapter->pdev->vendor)
 		return 1;
 
+	if (NX_IS_REVISION_P3(adapter->ahw.revision_id))
+		return 0;
+
 	data_written = (u32)0xa5a5a5a5;
 
 	NXWR32(adapter, CRB_SCRATCHPAD_TEST, data_written);
diff --git a/drivers/net/netxen/netxen_nic_hdr.h b/drivers/net/netxen/netxen_nic_hdr.h
index 622e4c8..d930068 100644
--- a/drivers/net/netxen/netxen_nic_hdr.h
+++ b/drivers/net/netxen/netxen_nic_hdr.h
@@ -789,9 +789,7 @@ enum {
  * for backward compability
  */
 #define CRB_NIC_CAPABILITIES_HOST	NETXEN_NIC_REG(0x1a8)
-#define CRB_NIC_CAPABILITIES_FW	  	NETXEN_NIC_REG(0x1dc)
 #define CRB_NIC_MSI_MODE_HOST		NETXEN_NIC_REG(0x270)
-#define CRB_NIC_MSI_MODE_FW	  	NETXEN_NIC_REG(0x274)
 
 #define INTR_SCHEME_PERPORT	      	0x1
 #define MSI_MODE_MULTIFUNC	      	0x1
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index 388feaf..4a2bbeb 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -1361,10 +1361,12 @@ int netxen_init_firmware(struct netxen_adapter *adapter)
 		return err;
 
 	NXWR32(adapter, CRB_NIC_CAPABILITIES_HOST, INTR_SCHEME_PERPORT);
-	NXWR32(adapter, CRB_NIC_MSI_MODE_HOST, MSI_MODE_MULTIFUNC);
 	NXWR32(adapter, CRB_MPORT_MODE, MPORT_MULTI_FUNCTION_MODE);
 	NXWR32(adapter, CRB_CMDPEG_STATE, PHAN_INITIALIZE_ACK);
 
+	if (NX_IS_REVISION_P2(adapter->ahw.revision_id))
+		NXWR32(adapter, CRB_NIC_MSI_MODE_HOST, MSI_MODE_MULTIFUNC);
+
 	return err;
 }
 
-- 
1.6.0.2

