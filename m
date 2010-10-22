From: Kyle McMartin <kyle@mcmartin.ca>
Subject: [PATCH] cxgb3: slay double assignment
Date: Fri, 22 Oct 2010 14:00:03 -0400
Message-ID: <20101022180003.GO8332@bombadil.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: divy@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:37564 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932503Ab0JVSAE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Oct 2010 14:00:04 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Noticed this while building Fedora today... It's been
there since around 2007, so I guess a new gcc must be catching
these.

Signed-off-by: Kyle McMartin <kyle@redhat.com>
---
diff --git a/drivers/net/cxgb3/t3_hw.c b/drivers/net/cxgb3/t3_hw.c
index 427c451..997b14b 100644
--- a/drivers/net/cxgb3/t3_hw.c
+++ b/drivers/net/cxgb3/t3_hw.c
@@ -3682,7 +3682,7 @@ static void mc7_prep(struct adapter *adapter, struct mc7 *mc7,
 	mc7->name = name;
 	mc7->offset = base_addr - MC7_PMRX_BASE_ADDR;
 	cfg = t3_read_reg(adapter, mc7->offset + A_MC7_CFG);
-	mc7->size = mc7->size = G_DEN(cfg) == M_DEN ? 0 : mc7_calc_size(cfg);
+	mc7->size = G_DEN(cfg) == M_DEN ? 0 : mc7_calc_size(cfg);
 	mc7->width = G_WIDTH(cfg);
 }
 
