From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCHv2 net-2.6] sfc: Really allow RX checksum offload to be
	disabled
Date: Wed, 28 Oct 2009 14:34:54 +0000
Message-ID: <1256740494.2846.19.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:34742 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751543AbZJ1Oex (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2009 10:34:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We have never checked the efx_nic::rx_checksum_enabled flag everywhere
we should, and since the switch to GRO we don't check it anywhere.
It's simplest to check it in the one place where we initialise the
per-packet checksummed flag.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
Cc: stable@kernel.org
---
This version really is applicable to net-2.6 and 2.6.31.y, and to
2.6.27.y with fuzz 1.  I'm not sure whether this bug is serious enough
for a stable update but it is an obvious fix.

Ben.

 drivers/net/sfc/falcon.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index c049364..e75674e 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -884,7 +884,9 @@ static void falcon_handle_rx_event(struct efx_channel *channel,
 		/* If packet is marked as OK and packet type is TCP/IPv4 or
 		 * UDP/IPv4, then we can rely on the hardware checksum.
 		 */
-		checksummed = RX_EV_HDR_TYPE_HAS_CHECKSUMS(rx_ev_hdr_type);
+		checksummed =
+			efx->rx_checksum_enabled &&
+			RX_EV_HDR_TYPE_HAS_CHECKSUMS(rx_ev_hdr_type);
 	} else {
 		falcon_handle_rx_not_ok(rx_queue, event, &rx_ev_pkt_ok,
 					&discard);

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

