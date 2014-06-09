From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH] amd-xgbe: Rename MAX_DMA_CHANNELS to avoid powerpc conflict
Date: Mon, 9 Jun 2014 09:19:32 -0500
Message-ID: <20140609141931.30639.72028.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <kbuild-all@01.org>, <jet.chen@intel.com>
To: <netdev@vger.kernel.org>, <fengguang.wu@intel.com>,
	<davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2lp0244.outbound.protection.outlook.com ([207.46.163.244]:32780
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750720AbaFIOTi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Jun 2014 10:19:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

MAX_DMA_CHANNELS is defined in asm/scatterlist.h of the powerpc
architecture.  Rename this #define in xgbe.h to avoid the
redefined warning issued during compilation.

Reported-by: Fengguang Wu <fengguang.wu@intel.com>
Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-main.c |    2 +-
 drivers/net/ethernet/amd/xgbe/xgbe.h      |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-main.c b/drivers/net/ethernet/amd/xgbe/xgbe-main.c
index b21f9b9..c83584a 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-main.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-main.c
@@ -230,7 +230,7 @@ static int xgbe_probe(struct platform_device *pdev)
 	DBGPR("--> xgbe_probe\n");
 
 	netdev = alloc_etherdev_mq(sizeof(struct xgbe_prv_data),
-				   MAX_DMA_CHANNELS);
+				   XGBE_MAX_DMA_CHANNELS);
 	if (!netdev) {
 		dev_err(dev, "alloc_etherdev failed\n");
 		ret = -ENOMEM;
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe.h b/drivers/net/ethernet/amd/xgbe/xgbe.h
index 9a5bfe6..ab06271 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe.h
+++ b/drivers/net/ethernet/amd/xgbe/xgbe.h
@@ -138,7 +138,7 @@
 #define RX_MIN_BUF_SIZE		(ETH_FRAME_LEN + ETH_FCS_LEN + VLAN_HLEN)
 #define RX_BUF_ALIGN		64
 
-#define MAX_DMA_CHANNELS	16
+#define XGBE_MAX_DMA_CHANNELS	16
 #define DMA_ARDOMAIN_SETTING	0x2
 #define DMA_ARCACHE_SETTING	0xb
 #define DMA_AWDOMAIN_SETTING	0x2
