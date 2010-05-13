From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 2/9] qlcnic: remove obsolete register
Date: Thu, 13 May 2010 06:07:43 -0700
Message-ID: <1273756070-7205-3-git-send-email-amit.salecha@qlogic.com>
References: <1273756070-7205-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:13292 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1758598Ab0EMNHx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 May 2010 09:07:53 -0400
In-Reply-To: <1273756070-7205-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

MSI_MODE, CAPABILITIES_FW and SCRATCHPAD registers are obsolete.
Driver should not use them.

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic_ethtool.c |    9 +--------
 drivers/net/qlcnic/qlcnic_hdr.h     |    7 -------
 drivers/net/qlcnic/qlcnic_init.c    |    1 -
 3 files changed, 1 insertions(+), 16 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_ethtool.c b/drivers/net/qlcnic/qlcnic_ethtool.c
index 6cdc5eb..e494ccc 100644
--- a/drivers/net/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/qlcnic/qlcnic_ethtool.c
@@ -606,19 +606,12 @@ qlcnic_set_pauseparam(struct net_device *netdev,
 static int qlcnic_reg_test(struct net_device *dev)
 {
 	struct qlcnic_adapter *adapter = netdev_priv(dev);
-	u32 data_read, data_written;
+	u32 data_read;
 
 	data_read = QLCRD32(adapter, QLCNIC_PCIX_PH_REG(0));
 	if ((data_read & 0xffff) != adapter->pdev->vendor)
 		return 1;
 
-	data_written = (u32)0xa5a5a5a5;
-
-	QLCWR32(adapter, CRB_SCRATCHPAD_TEST, data_written);
-	data_read = QLCRD32(adapter, CRB_SCRATCHPAD_TEST);
-	if (data_written != data_read)
-		return 1;
-
 	return 0;
 }
 
diff --git a/drivers/net/qlcnic/qlcnic_hdr.h b/drivers/net/qlcnic/qlcnic_hdr.h
index a984cd2..1374078 100644
--- a/drivers/net/qlcnic/qlcnic_hdr.h
+++ b/drivers/net/qlcnic/qlcnic_hdr.h
@@ -585,15 +585,8 @@ enum {
  * for backward compability
  */
 #define CRB_NIC_CAPABILITIES_HOST	QLCNIC_REG(0x1a8)
-#define CRB_NIC_CAPABILITIES_FW 	QLCNIC_REG(0x1dc)
-#define CRB_NIC_MSI_MODE_HOST		QLCNIC_REG(0x270)
-#define CRB_NIC_MSI_MODE_FW	  	QLCNIC_REG(0x274)
 
 #define INTR_SCHEME_PERPORT	      	0x1
-#define MSI_MODE_MULTIFUNC	      	0x1
-
-/* used for ethtool tests */
-#define CRB_SCRATCHPAD_TEST	    QLCNIC_REG(0x280)
 
 /*
  * CrbPortPhanCntrHi/Lo is used to pass the address of HostPhantomIndex address
diff --git a/drivers/net/qlcnic/qlcnic_init.c b/drivers/net/qlcnic/qlcnic_init.c
index 1b621ca..9b01042 100644
--- a/drivers/net/qlcnic/qlcnic_init.c
+++ b/drivers/net/qlcnic/qlcnic_init.c
@@ -1189,7 +1189,6 @@ int qlcnic_init_firmware(struct qlcnic_adapter *adapter)
 		return err;
 
 	QLCWR32(adapter, CRB_NIC_CAPABILITIES_HOST, INTR_SCHEME_PERPORT);
-	QLCWR32(adapter, CRB_NIC_MSI_MODE_HOST, MSI_MODE_MULTIFUNC);
 	QLCWR32(adapter, CRB_MPORT_MODE, MPORT_MULTI_FUNCTION_MODE);
 	QLCWR32(adapter, CRB_CMDPEG_STATE, PHAN_INITIALIZE_ACK);
 
-- 
1.6.0.2

