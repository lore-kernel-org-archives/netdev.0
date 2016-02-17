From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next] bnx2x: Add missing HSI for big-endian machines
Date: Wed, 17 Feb 2016 13:15:14 +0200
Message-ID: <1455707714-5262-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:25636 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1161108AbcBQLP0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2016 06:15:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit e5d3a51cefbb "bnx2x: extend DCBx support" was missing HSI changes
for big-endian machine, breaking compilation on such platforms.

Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
Hi Dave,

Sorry about this. Please consider applying this to `net-next'.

Thanks,
Yuval
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
index dd9d6e6..04523d4 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
@@ -1824,10 +1824,12 @@ struct dcbx_app_priority_entry {
 	u8  pri_bitmap;
 	u8  appBitfield;
 	#define DCBX_APP_ENTRY_VALID         0x01
-	#define DCBX_APP_ENTRY_SF_MASK       0x30
+	#define DCBX_APP_ENTRY_SF_MASK       0xF0
 	#define DCBX_APP_ENTRY_SF_SHIFT      4
 	#define DCBX_APP_SF_ETH_TYPE         0x10
 	#define DCBX_APP_SF_PORT             0x20
+	#define DCBX_APP_SF_UDP              0x40
+	#define DCBX_APP_SF_DEFAULT          0x80
 #elif defined(__LITTLE_ENDIAN)
 	u8 appBitfield;
 	#define DCBX_APP_ENTRY_VALID         0x01
-- 
1.9.3
