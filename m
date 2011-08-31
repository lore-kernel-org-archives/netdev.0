From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 11/14] qla3xxx: convert to SKB paged frag API.
Date: Wed, 31 Aug 2011 11:47:03 +0100
Message-ID: <1314787626-12273-11-git-send-email-ian.campbell@citrix.com>
References: <1314787608.28989.41.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ian Campbell <ian.campbell@citrix.com>,
	Ron Mercer <ron.mercer@qlogic.com>, linux-driver@qlogic.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:10632 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754561Ab1HaKrW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2011 06:47:22 -0400
In-Reply-To: <1314787608.28989.41.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: Ron Mercer <ron.mercer@qlogic.com>
Cc: linux-driver@qlogic.com
Cc: netdev@vger.kernel.org
---
 drivers/net/ethernet/qlogic/qla3xxx.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qla3xxx.c b/drivers/net/ethernet/qlogic/qla3xxx.c
index 8cab61c..1871d88 100644
--- a/drivers/net/ethernet/qlogic/qla3xxx.c
+++ b/drivers/net/ethernet/qlogic/qla3xxx.c
@@ -2388,9 +2388,8 @@ static int ql_send_map(struct ql3_adapter *qdev,
 			seg++;
 		}
 
-		map = pci_map_page(qdev->pdev, frag->page,
-				   frag->page_offset, frag->size,
-				   PCI_DMA_TODEVICE);
+		map = skb_frag_dma_map(&qdev->pdev->dev, frag, 0, frag->size,
+				       PCI_DMA_TODEVICE);
 
 		err = pci_dma_mapping_error(qdev->pdev, map);
 		if (err) {
-- 
1.7.2.5
