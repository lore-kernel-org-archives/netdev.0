From: Vasanthy Kolluri <vkolluri@cisco.com>
Subject: [net-2.6 PATCH] enic: Bug Fix: Pass napi reference to the isr that
	services receive queue
Date: Wed, 08 Dec 2010 15:05:45 -0800
Message-ID: <20101208230545.24082.48614.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roprabhu@cisco.com, dwang2@cisco.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-5.cisco.com ([171.68.10.87]:11652 "EHLO
	sj-iport-5.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756369Ab0LHXFq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Dec 2010 18:05:46 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasanthy Kolluri <vkolluri@cisco.com>

Pass reference to napi instead of enic device to the isr that services receive queue.

Signed-off-by: Vasanthy Kolluri <vkolluri@cisco.com>
Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
Signed-off-by: David Wang <dwang2@cisco.com>
---
 drivers/net/enic/enic_main.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)


diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
index a466ef9..aa28b27 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -1962,7 +1962,8 @@ static void enic_poll_controller(struct net_device *netdev)
 	case VNIC_DEV_INTR_MODE_MSIX:
 		for (i = 0; i < enic->rq_count; i++) {
 			intr = enic_msix_rq_intr(enic, i);
-			enic_isr_msix_rq(enic->msix_entry[intr].vector, enic);
+			enic_isr_msix_rq(enic->msix_entry[intr].vector,
+				&enic->napi[i]);
 		}
 		intr = enic_msix_wq_intr(enic, i);
 		enic_isr_msix_wq(enic->msix_entry[intr].vector, enic);

