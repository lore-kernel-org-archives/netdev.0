From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 2/5] qlge: bugfix: Add missing pci_unmap_page call in receive path.
Date: Wed, 24 Dec 2008 10:21:33 -0800
Message-ID: <1230142896-15533-2-git-send-email-ron.mercer@qlogic.com>
References: <20081224181834.GA15470@susedev.qlogic.org>
Cc: ron.mercer@qlogic.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:27618 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751214AbYLXSVf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Dec 2008 13:21:35 -0500
In-Reply-To: <20081224181834.GA15470@susedev.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 56c7531..92dc3f7 100755
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -1308,6 +1308,11 @@ static struct sk_buff *ql_build_rx_skb(struct ql_adapter *qdev,
 					"No skb available, drop the packet.\n");
 				return NULL;
 			}
+			pci_unmap_page(qdev->pdev,
+				       pci_unmap_addr(lbq_desc,
+						      mapaddr),
+				       pci_unmap_len(lbq_desc, maplen),
+				       PCI_DMA_FROMDEVICE);
 			skb_reserve(skb, NET_IP_ALIGN);
 			QPRINTK(qdev, RX_STATUS, DEBUG,
 				"%d bytes of headers and data in large. Chain page to new skb and pull tail.\n", length);
-- 
1.6.0

