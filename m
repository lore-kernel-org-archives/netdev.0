From: Rasesh Mody <rmody@brocade.com>
Subject: [PATCH 23/45] bna: Added Defines for Multi TXQ Support
Date: Mon, 18 Jul 2011 01:22:43 -0700
Message-ID: <1310977385-5268-13-git-send-email-rmody@brocade.com>
References: <1310977385-5268-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>, <dradovan@brocade.com>,
	Rasesh Mody <rmody@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:37803 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753345Ab1GRIYH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2011 04:24:07 -0400
In-Reply-To: <1310977385-5268-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chnage details:
 - Added new Macros - bna_prio_allow(), bna_iscsi_prio(), bna_default_nw_prio(),
   bna_is_iscsi_over_cee(), bna_is_prio_reconfig()
 - Construction of priority indirection table to be used by bnad to direct
   packets into TxQs
 - Making available valid priority map, iscsi priority, default priority
   and priority indirection table to bnad through macros
 - Set/reset prio_reconfigured when txq reconfigured/not reconfigured

Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/bna/bna.h |   11 +++++++++++
 1 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bna/bna.h b/drivers/net/bna/bna.h
index b342bdb..518f3dd 100644
--- a/drivers/net/bna/bna.h
+++ b/drivers/net/bna/bna.h
@@ -32,6 +32,7 @@ extern u32 bna_napi_dim_vector[][BNA_BIAS_T_MAX];
 #define BNA_MESSAGE_SIZE		256
 
 #define bna_is_small_rxq(_id) ((_id) & 0x1)
+#define bna_is_header_rxq(_id) bna_is_small_rxq(_id)
 
 #define BNA_MAC_IS_EQUAL(_mac1, _mac2)					\
 	(!memcmp((_mac1), (_mac2), sizeof(mac_t)))
@@ -351,6 +352,16 @@ do {									\
 	}								\
 } while (0)
 
+#define bna_prio_allowed(_bna, _prio) ((_bna)->tx_mod.prio_map & (1 << _prio))
+
+#define bna_iscsi_prio(_bna) ((_bna)->tx_mod.iscsi_prio)
+
+#define bna_default_prio(_bna) ((_bna)->tx_mod.default_prio)
+
+#define bna_is_iscsi_over_cee(_bna) ((_bna)->tx_mod.iscsi_over_cee)
+
+#define bna_is_prio_reconfig(_bna) ((_bna)->tx_mod.prio_reconfigured)
+
 /**
  *
  *  Inline functions
-- 
1.7.1

