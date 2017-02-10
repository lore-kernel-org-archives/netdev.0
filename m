From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next] sfc: fix swapped arguments to
 efx_ef10_handle_rx_event_errors
Date: Fri, 10 Feb 2017 17:34:59 +0000
Message-ID: <3d0f460b-b283-4157-33a4-0c30257a1cba@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: <linux-net-drivers@solarflare.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:13247 "EHLO
        nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751989AbdBJS7X (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2017 13:59:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixes: a0ee35414837 ("sfc: process RX event inner checksum flags")
Reported-by: Colin Ian King <colin.king@canonical.com>
Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 6bba2d2..761ccc6 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -3356,8 +3356,9 @@ static int efx_ef10_handle_rx_event(struct efx_channel *channel,
 	EFX_AND_QWORD(errors, *event, errors);
 	if (unlikely(!EFX_QWORD_IS_ZERO(errors))) {
 		flags |= efx_ef10_handle_rx_event_errors(channel, n_packets,
+							 rx_encap_hdr,
 							 rx_l3_class, rx_l4_class,
-							 rx_encap_hdr, event);
+							 event);
 	} else {
 		bool tcpudp = rx_l4_class == ESE_DZ_L4_CLASS_TCP ||
 			      rx_l4_class == ESE_DZ_L4_CLASS_UDP;
