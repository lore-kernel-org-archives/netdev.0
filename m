From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/17] fm10k: add TEB check to fm10k_gre_is_nvgre
Date: Thu,  3 Dec 2015 16:29:47 -0800
Message-ID: <1449188994-64940-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1449188994-64940-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:14336 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754326AbbLDA36 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Dec 2015 19:29:58 -0500
In-Reply-To: <1449188994-64940-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

The NVGRE protocol should be run over transparent ethernet bridge
protocol, so we should verify this in our check whether the GRE tunnel
is NVGRE. While we're touching fm10k_main.c, update the copyright year.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Reviewed-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_main.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_main.c b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
index 746a198..c5f7e0d 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_main.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_main.c
@@ -1,5 +1,5 @@
 /* Intel Ethernet Switch Host Interface Driver
- * Copyright(c) 2013 - 2014 Intel Corporation.
+ * Copyright(c) 2013 - 2015 Intel Corporation.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms and conditions of the GNU General Public License,
@@ -708,6 +708,10 @@ static struct ethhdr *fm10k_gre_is_nvgre(struct sk_buff *skb)
 	if (nvgre_hdr->flags & FM10K_NVGRE_RESERVED0_FLAGS)
 		return NULL;
 
+	/* verify protocol is transparent Ethernet bridging */
+	if (nvgre_hdr->proto != htons(ETH_P_TEB))
+		return NULL;
+
 	/* report start of ethernet header */
 	if (nvgre_hdr->flags & NVGRE_TNI)
 		return (struct ethhdr *)(nvgre_hdr + 1);
-- 
2.5.0
