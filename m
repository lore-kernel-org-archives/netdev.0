From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 2/5] qlge: bugfix: Add missing pci_unmap_page call in receive path.
Date: Tue, 30 Dec 2008 13:12:22 -0800
Message-ID: <1230671545-19084-2-git-send-email-ron.mercer@qlogic.com>
References: <20081230211122.GD16018@susedev.qlogic.org>
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com,
	ron.mercer@qlogic.com, bhutchings@solarflare.com, hch@infradead.org
To: davem@davemloft.net, jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:38470 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752237AbYL3VMY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Dec 2008 16:12:24 -0500
In-Reply-To: <20081230211122.GD16018@susedev.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index c6ab6a4..9ceedfc 100644
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

