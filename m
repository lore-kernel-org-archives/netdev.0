From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH 3/3] netxen: fix caching window register
Date: Mon, 14 Jun 2010 02:39:05 -0700
Message-ID: <1276508345-17070-4-git-send-email-amit.salecha@qlogic.com>
References: <1276508345-17070-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:42620 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1755815Ab0FNJjG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Jun 2010 05:39:06 -0400
In-Reply-To: <1276508345-17070-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CRB window register is not per pci-func for NX3031,
so caching can result in incorrect values.

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/netxen/netxen_nic_hw.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index 5c496f8..29d7b93 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -1159,9 +1159,6 @@ netxen_nic_pci_set_crbwindow_2M(struct netxen_adapter *adapter, ulong off)
 
 	window = CRB_HI(off);
 
-	if (adapter->ahw.crb_win == window)
-		return;
-
 	writel(window, addr);
 	if (readl(addr) != window) {
 		if (printk_ratelimit())
@@ -1169,7 +1166,6 @@ netxen_nic_pci_set_crbwindow_2M(struct netxen_adapter *adapter, ulong off)
 				"failed to set CRB window to %d off 0x%lx\n",
 				window, off);
 	}
-	adapter->ahw.crb_win = window;
 }
 
 static void __iomem *
-- 
1.6.0.2

