From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 03/10] sfc: Remove dead write to
 tso_state::packet_space
Date: Tue, 17 Jul 2012 19:06:09 +0100
Message-ID: <1342548369.2698.21.camel@bwh-desktop.uk.solarflarecom.com>
References: <1342544740.2698.13.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:49397 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753259Ab2GQSGM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 14:06:12 -0400
In-Reply-To: <1342544740.2698.13.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

tso_state::packet_space is always set in tso_start_packet(); the
value set in tso_start() is not used, and is also incorrect.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/tx.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/sfc/tx.c b/drivers/net/ethernet/sfc/tx.c
index 18860f2..cfa5f6d 100644
--- a/drivers/net/ethernet/sfc/tx.c
+++ b/drivers/net/ethernet/sfc/tx.c
@@ -926,7 +926,6 @@ static void tso_start(struct tso_state *st, const struct sk_buff *skb)
 	EFX_BUG_ON_PARANOID(tcp_hdr(skb)->syn);
 	EFX_BUG_ON_PARANOID(tcp_hdr(skb)->rst);
 
-	st->packet_space = st->full_packet_size;
 	st->out_len = skb->len - st->header_len;
 	st->unmap_len = 0;
 	st->unmap_single = false;
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
