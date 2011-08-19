From: Ian Campbell <ian.campbell@citrix.com>
Subject: [PATCH 13/75] atl1c: convert to SKB paged frag API.
Date: Fri, 19 Aug 2011 14:26:45 +0100
Message-ID: <1313760467-8598-13-git-send-email-ian.campbell@citrix.com>
References: <1313760393.5010.356.camel@zakaz.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	Ian Campbell <ian.campbell@citrix.com>,
	"David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	=?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:26037 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754157Ab1HSN2S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2011 09:28:18 -0400
In-Reply-To: <1313760393.5010.356.camel@zakaz.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Stephen Hemminger <shemminger@vyatta.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: "Micha=C5=82 Miros=C5=82aw" <mirq-linux@rere.qmqm.pl>
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org
---
 drivers/net/atl1c/atl1c_main.c |    9 ++++-----
 1 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/atl1c/atl1c_main.c b/drivers/net/atl1c/atl1c_m=
ain.c
index 9722442..7ecb30c 100644
--- a/drivers/net/atl1c/atl1c_main.c
+++ b/drivers/net/atl1c/atl1c_main.c
@@ -2180,11 +2180,10 @@ static void atl1c_tx_map(struct atl1c_adapter *=
adapter,
=20
 		buffer_info =3D atl1c_get_tx_buffer(adapter, use_tpd);
 		buffer_info->length =3D frag->size;
-		buffer_info->dma =3D
-			pci_map_page(adapter->pdev, frag->page,
-					frag->page_offset,
-					buffer_info->length,
-					PCI_DMA_TODEVICE);
+		buffer_info->dma =3D skb_frag_dma_map(&adapter->pdev->dev,
+						    frag, 0,
+						    buffer_info->length,
+						    PCI_DMA_TODEVICE);
 		ATL1C_SET_BUFFER_STATE(buffer_info, ATL1C_BUFFER_BUSY);
 		ATL1C_SET_PCIMAP_TYPE(buffer_info, ATL1C_PCIMAP_PAGE,
 			ATL1C_PCIMAP_TODEVICE);
--=20
1.7.2.5

