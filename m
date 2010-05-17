From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 6/7] qlcnic: remove unused register
Date: Mon, 17 May 2010 04:22:13 -0700
Message-ID: <1274095334-32362-7-git-send-email-amit.salecha@qlogic.com>
References: <1274095334-32362-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:48303 "EHLO
	dut4145.unminc.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754079Ab0EQKVw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 May 2010 06:21:52 -0400
In-Reply-To: <1274095334-32362-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Removing register defines which are not used by Qlgoic CNA device.

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h      |    2 --
 drivers/net/qlcnic/qlcnic_hdr.h  |   16 ----------------
 drivers/net/qlcnic/qlcnic_init.c |    2 --
 drivers/net/qlcnic/qlcnic_main.c |    1 -
 4 files changed, 0 insertions(+), 21 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index 2ed34cd..896d40d 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -149,8 +149,6 @@
 #define get_next_index(index, length)	\
 	(((index) + 1) & ((length) - 1))
 
-#define MPORT_MULTI_FUNCTION_MODE 0x2222
-
 /*
  * Following data structures describe the descriptors that will be used.
  * Added fileds of tcpHdrSize and ipHdrSize, The driver needs to do it only when
diff --git a/drivers/net/qlcnic/qlcnic_hdr.h b/drivers/net/qlcnic/qlcnic_hdr.h
index 1374078..ad9d167 100644
--- a/drivers/net/qlcnic/qlcnic_hdr.h
+++ b/drivers/net/qlcnic/qlcnic_hdr.h
@@ -563,32 +563,16 @@ enum {
 #define CRB_PF_LINK_SPEED_1		(QLCNIC_REG(0xe8))
 #define CRB_PF_LINK_SPEED_2		(QLCNIC_REG(0xec))
 
-#define CRB_MPORT_MODE			(QLCNIC_REG(0xc4))
-#define CRB_DMA_SHIFT			(QLCNIC_REG(0xcc))
-
 #define CRB_TEMP_STATE			(QLCNIC_REG(0x1b4))
 
 #define CRB_V2P_0			(QLCNIC_REG(0x290))
 #define CRB_V2P(port)			(CRB_V2P_0+((port)*4))
 #define CRB_DRIVER_VERSION		(QLCNIC_REG(0x2a0))
 
-#define CRB_SW_INT_MASK_0		(QLCNIC_REG(0x1d8))
-#define CRB_SW_INT_MASK_1		(QLCNIC_REG(0x1e0))
-#define CRB_SW_INT_MASK_2		(QLCNIC_REG(0x1e4))
-#define CRB_SW_INT_MASK_3		(QLCNIC_REG(0x1e8))
-
 #define CRB_FW_CAPABILITIES_1		(QLCNIC_CAM_RAM(0x128))
 #define CRB_MAC_BLOCK_START		(QLCNIC_CAM_RAM(0x1c0))
 
 /*
- * capabilities register, can be used to selectively enable/disable features
- * for backward compability
- */
-#define CRB_NIC_CAPABILITIES_HOST	QLCNIC_REG(0x1a8)
-
-#define INTR_SCHEME_PERPORT	      	0x1
-
-/*
  * CrbPortPhanCntrHi/Lo is used to pass the address of HostPhantomIndex address
  * which can be read by the Phantom host to get producer/consumer indexes from
  * Phantom/Casper. If it is not HOST_SHARED_MEMORY, then the following
diff --git a/drivers/net/qlcnic/qlcnic_init.c b/drivers/net/qlcnic/qlcnic_init.c
index dccd8c3..71a4e66 100644
--- a/drivers/net/qlcnic/qlcnic_init.c
+++ b/drivers/net/qlcnic/qlcnic_init.c
@@ -1184,8 +1184,6 @@ int qlcnic_init_firmware(struct qlcnic_adapter *adapter)
 	if (err)
 		return err;
 
-	QLCWR32(adapter, CRB_NIC_CAPABILITIES_HOST, INTR_SCHEME_PERPORT);
-	QLCWR32(adapter, CRB_MPORT_MODE, MPORT_MULTI_FUNCTION_MODE);
 	QLCWR32(adapter, CRB_CMDPEG_STATE, PHAN_INITIALIZE_ACK);
 
 	return err;
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index dde1e8a..f8bd1bd 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -606,7 +606,6 @@ qlcnic_start_firmware(struct qlcnic_adapter *adapter)
 		msleep(1);
 	}
 
-	QLCWR32(adapter, CRB_DMA_SHIFT, 0x55555555);
 	QLCWR32(adapter, QLCNIC_PEG_HALT_STATUS1, 0);
 	QLCWR32(adapter, QLCNIC_PEG_HALT_STATUS2, 0);
 
-- 
1.5.6.1

