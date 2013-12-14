From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 14/15] sfc: Don't clear timestamps in efx_ptp_rx()
Date: Sat, 14 Dec 2013 23:07:16 +0000
Message-ID: <1387062436.12172.72.camel@deadeye.wl.decadent.org.uk>
References: <1387061852.12172.58.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	"Richard Cochran" <richardcochran@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:17443 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753858Ab3LNXHV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Dec 2013 18:07:21 -0500
In-Reply-To: <1387061852.12172.58.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A freshly allocated skb starts with timestamps clear.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/ptp.c |    6 ------
 1 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ptp.c b/drivers/net/ethernet/sfc/ptp.c
index fe3c6d04fce8..06c6420f40d7 100644
--- a/drivers/net/ethernet/sfc/ptp.c
+++ b/drivers/net/ethernet/sfc/ptp.c
@@ -1323,14 +1323,8 @@ static bool efx_ptp_rx(struct efx_channel *channel, struct sk_buff *skb)
 
 	/* Does this packet require timestamping? */
 	if (ntohs(*(__be16 *)&skb->data[PTP_DPORT_OFFSET]) == PTP_EVENT_PORT) {
-		struct skb_shared_hwtstamps *timestamps;
-
 		match->state = PTP_PACKET_STATE_UNMATCHED;
 
-		/* Clear all timestamps held: filled in later */
-		timestamps = skb_hwtstamps(skb);
-		memset(timestamps, 0, sizeof(*timestamps));
-
 		/* We expect the sequence number to be in the same position in
 		 * the packet for PTP V1 and V2
 		 */


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
