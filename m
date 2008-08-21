From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 1/1] r8169: balance pci_map / pci_unmap pair
Date: Thu, 21 Aug 2008 23:47:34 +0200
Message-ID: <20080821214734.GB22540@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=unknown-8bit
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Ilpo =?unknown-8bit?B?SsOkcnZpbmVu?= <ilpo.jarvinen@helsinki.fi>,
	Alistair John Strachan <alistair@devzero.co.uk>,
	Timothy J Fontaine <tjfontaine@atxconsulting.com>,
	Edward Hsu <edward_hsu@realtek.com.tw>,
	Andrew Morton <akpm@linux-foundation.org>,
	Ivan Vecera <ivecera@redhat.com>
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:58496 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754608AbYHUVuF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 17:50:05 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The leak hurts with swiotlb and jumbo frames (see
http://bugzilla.kernel.org/show_bug.cgi?id=3D9468).

Heavily hinted by Ilpo J=C3=A4rvinen <ilpo.jarvinen@helsinki.fi>.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Tested-by: Alistair John Strachan <alistair@devzero.co.uk>
Tested-by: Timothy J Fontaine <tjfontaine@atxconsulting.com>
Cc: Edward Hsu <edward_hsu@realtek.com.tw>
---
 drivers/net/r8169.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index a3e3895..0f6f974 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -2792,7 +2792,7 @@ static int rtl8169_rx_interrupt(struct net_device=
 *dev,
 					pkt_size, PCI_DMA_FROMDEVICE);
 				rtl8169_mark_to_asic(desc, tp->rx_buf_sz);
 			} else {
-				pci_unmap_single(pdev, addr, pkt_size,
+				pci_unmap_single(pdev, addr, tp->rx_buf_sz,
 						 PCI_DMA_FROMDEVICE);
 				tp->Rx_skbuff[entry] =3D NULL;
 			}
--=20
1.5.3.3

