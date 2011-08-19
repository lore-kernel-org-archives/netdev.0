From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 14/75] atl1e: convert to SKB paged frag API.
Date: Fri, 19 Aug 2011 14:26:46 +0100
Message-ID: <1313760467-8598-14-git-send-email-ian.campbell@citrix.com>
References: <1313760393.5010.356.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	Ian Campbell <ian.campbell@citrix.com>,
	"David S. Miller" <davem@davemloft.net>,
	Joe Perches <joe@perches.com>,
	=?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Jon Mason <jdmason@kudzu.us>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:26037 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754181Ab1HSN2U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2011 09:28:20 -0400
In-Reply-To: <1313760393.5010.356.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Joe Perches <joe@perches.com>
Cc: "Micha=C5=82 Miros=C5=82aw" <mirq-linux@rere.qmqm.pl>
Cc: Stephen Hemminger <shemminger@vyatta.com>
Cc: Jon Mason <jdmason@kudzu.us>
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
---
 drivers/net/atl1e/atl1e_main.c |   11 +++++------
 1 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/drivers/net/atl1e/atl1e_main.c b/drivers/net/atl1e/atl1e_m=
ain.c
index d8d4119..637134d 100644
--- a/drivers/net/atl1e/atl1e_main.c
+++ b/drivers/net/atl1e/atl1e_main.c
@@ -1765,12 +1765,11 @@ static void atl1e_tx_map(struct atl1e_adapter *=
adapter,
 				MAX_TX_BUF_LEN : buf_len;
 			buf_len -=3D tx_buffer->length;
=20
-			tx_buffer->dma =3D
-				pci_map_page(adapter->pdev, frag->page,
-						frag->page_offset +
-						(i * MAX_TX_BUF_LEN),
-						tx_buffer->length,
-						PCI_DMA_TODEVICE);
+			tx_buffer->dma =3D skb_frag_dma_map(&adapter->pdev->dev,
+							  frag,
+							  (i * MAX_TX_BUF_LEN),
+							  tx_buffer->length,
+							  PCI_DMA_TODEVICE);
 			ATL1E_SET_PCIMAP_TYPE(tx_buffer, ATL1E_TX_PCIMAP_PAGE);
 			use_tpd->buffer_addr =3D cpu_to_le64(tx_buffer->dma);
 			use_tpd->word2 =3D (use_tpd->word2 & (~TPD_BUFLEN_MASK)) |
--=20
1.7.2.5

