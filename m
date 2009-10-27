From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-2.6] sfc: Really allow RX checksum offload to be
	disabled
Date: Tue, 27 Oct 2009 19:44:33 +0000
Message-ID: <1256672673.2794.7.camel@achroite>
References: <1256655057.2794.4.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:55912 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753566AbZJ0Tom (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2009 15:44:42 -0400
In-Reply-To: <1256655057.2794.4.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We have never checked the efx_nic::rx_checksum_enabled flag everywhere
we should, and since the switch to GRO we don't check it anywhere.
It's simplest to check it in the one place where we initialise the
per-packet checksummed flag.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
Cc: stable@kernel.org
---
I'm not sure whether this is serious enough to merit a stable update.
It's not a recent regression.

Ben.

 drivers/net/sfc/falcon.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 8776432..865638b 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -869,8 +869,9 @@ static void falcon_handle_rx_event(struct efx_channel *channel,
 		 * UDP/IPv4, then we can rely on the hardware checksum.
 		 */
 		checksummed =
-			rx_ev_hdr_type == FSE_AB_RX_EV_HDR_TYPE_IPV4_TCP ||
-			rx_ev_hdr_type == FSE_AB_RX_EV_HDR_TYPE_IPV4_UDP;
+			efx->rx_checksum_enabled &&
+			(rx_ev_hdr_type == FSE_AB_RX_EV_HDR_TYPE_IPV4_TCP ||
+			 rx_ev_hdr_type == FSE_AB_RX_EV_HDR_TYPE_IPV4_UDP);
 	} else {
 		falcon_handle_rx_not_ok(rx_queue, event, &rx_ev_pkt_ok,
 					&discard);

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

