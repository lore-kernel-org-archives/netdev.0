From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 9/9] cxgb4vf: Update to 128 byte mailbox size for T6 adapter
Date: Wed, 23 Dec 2015 22:47:19 +0530
Message-ID: <1450891039-17196-10-git-send-email-hariprasad@chelsio.com>
References: <1450891039-17196-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:30852 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S933316AbbLWRQ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2015 12:16:27 -0500
In-Reply-To: <1450891039-17196-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_defs.h |  1 +
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c   | 11 +++++++++--
 2 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_defs.h b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_defs.h
index b516b12..f859db3 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_defs.h
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_defs.h
@@ -54,6 +54,7 @@
 #define T4VF_MPS_BASE_ADDR	0x0100
 #define T4VF_PL_BASE_ADDR	0x0200
 #define T4VF_MBDATA_BASE_ADDR	0x0240
+#define T6VF_MBDATA_BASE_ADDR	0x0280
 #define T4VF_CIM_BASE_ADDR	0x0300
 
 #define T4VF_REGMAP_START	0x0000
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
index 63dd5fd..b6fa74a 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
@@ -120,12 +120,19 @@ int t4vf_wr_mbox_core(struct adapter *adapter, const void *cmd, int size,
 		1, 1, 3, 5, 10, 10, 20, 50, 100
 	};
 
-	u32 v;
+	u32 v, mbox_data;
 	int i, ms, delay_idx;
 	const __be64 *p;
-	u32 mbox_data = T4VF_MBDATA_BASE_ADDR;
 	u32 mbox_ctl = T4VF_CIM_BASE_ADDR + CIM_VF_EXT_MAILBOX_CTRL;
 
+	/* In T6, mailbox size is changed to 128 bytes to avoid
+	 * invalidating the entire prefetch buffer.
+	 */
+	if (CHELSIO_CHIP_VERSION(adapter->params.chip) <= CHELSIO_T5)
+		mbox_data = T4VF_MBDATA_BASE_ADDR;
+	else
+		mbox_data = T6VF_MBDATA_BASE_ADDR;
+
 	/*
 	 * Commands must be multiples of 16 bytes in length and may not be
 	 * larger than the size of the Mailbox Data register array.
-- 
2.3.4
