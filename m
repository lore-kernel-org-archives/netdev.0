From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 42/75] qla3xxx: convert to SKB paged frag API.
Date: Fri, 19 Aug 2011 14:27:14 +0100
Message-ID: <1313760467-8598-42-git-send-email-ian.campbell@citrix.com>
References: <1313760393.5010.356.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org,
	Ian Campbell <ian.campbell@citrix.com>,
	Ron Mercer <ron.mercer@qlogic.com>, linux-driver@qlogic.com
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1313760393.5010.356.camel@zakaz.uk.xensource.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: Ron Mercer <ron.mercer@qlogic.com>
Cc: linux-driver@qlogic.com
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
---
 drivers/net/qla3xxx.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
index 2f69140..8b1e7b5 100644
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
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
