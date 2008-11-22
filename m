From: Scott Feldman <scofeldm@cisco.com>
Subject: [PATCH 3/5] enic: mask off some reserved bits in CQ descriptor for
	future use
Date: Fri, 21 Nov 2008 16:34:08 -0800
Message-ID: <20081122003408.15540.33764.stgit@palito_client100.nuovasystems.com>
References: <20081122003219.15540.26759.stgit@palito_client100.nuovasystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1.cisco.com ([171.71.176.70]:21567 "EHLO
	sj-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754719AbYKVAlq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 19:41:46 -0500
In-Reply-To: <20081122003219.15540.26759.stgit@palito_client100.nuovasystems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

enic: mask off some reserved bits in CQ descriptor for future use



Signed-off-by: Scott Feldman <scofeldm@cisco.com>
---
 drivers/net/enic/cq_desc.h |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/enic/cq_desc.h b/drivers/net/enic/cq_desc.h
index c036a8b..1eb289f 100644
--- a/drivers/net/enic/cq_desc.h
+++ b/drivers/net/enic/cq_desc.h
@@ -44,9 +44,10 @@ struct cq_desc {
 	u8 type_color;
 };
 
-#define CQ_DESC_TYPE_BITS        7
+#define CQ_DESC_TYPE_BITS        4
 #define CQ_DESC_TYPE_MASK        ((1 << CQ_DESC_TYPE_BITS) - 1)
 #define CQ_DESC_COLOR_MASK       1
+#define CQ_DESC_COLOR_SHIFT      7
 #define CQ_DESC_Q_NUM_BITS       10
 #define CQ_DESC_Q_NUM_MASK       ((1 << CQ_DESC_Q_NUM_BITS) - 1)
 #define CQ_DESC_COMP_NDX_BITS    12
@@ -58,7 +59,7 @@ static inline void cq_desc_dec(const struct cq_desc *desc_arg,
 	const struct cq_desc *desc = desc_arg;
 	const u8 type_color = desc->type_color;
 
-	*color = (type_color >> CQ_DESC_TYPE_BITS) & CQ_DESC_COLOR_MASK;
+	*color = (type_color >> CQ_DESC_COLOR_SHIFT) & CQ_DESC_COLOR_MASK;
 
 	/*
 	 * Make sure color bit is read from desc *before* other fields

