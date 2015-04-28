From: Vlastimil Setka <setka@vsis.cz>
Subject: [PATCH] altera_tse: Correct rx packet length
Date: Wed, 29 Apr 2015 00:17:11 +0200
Message-ID: <554006E7.1050806@vsis.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: 7bit
To: vbridger@opensource.altera.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.spsostrov.cz ([217.117.209.230]:35272 "EHLO
	mail.spsostrov.cz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030901AbbD1WlG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2015 18:41:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlastimil Setka <setka@vsis.cz>

Altera TSE MAC rx DMA transfer starts with the 2 additional bytes for IP
payload alignment. This patch fixes tse_rx() function loop which reads DMA
rx status and extracts packet length from it. Status signalises a whole DMA
transfer length, which is 2 bytes longer than the packet itself.

Signed-off-by: Vlastimil Setka <setka@vsis.cz>
---
 drivers/net/ethernet/altera/altera_tse_main.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/ethernet/altera/altera_tse_main.c b/drivers/net/ethernet/altera/altera_tse_main.c
index 90a7630..592ef28 100644
--- a/drivers/net/ethernet/altera/altera_tse_main.c
+++ b/drivers/net/ethernet/altera/altera_tse_main.c
@@ -391,6 +391,12 @@ static int tse_rx(struct altera_tse_private *priv, int limit)
 				   "RCV pktstatus %08X pktlength %08X\n",
 				   pktstatus, pktlength);
 
+		/* DMA trasfer from TSE starts with 2 aditional bytes for
+		 * IP payload alignment. Status returned by get_rx_status()
+		 * contains DMA transfer length. Packet is 2 bytes shorter.
+		 */
+		pktlength -= 2;
+
 		count++;
 		next_entry = (++priv->rx_cons) % priv->rx_ring_size;
 
-- 
1.8.1.2
