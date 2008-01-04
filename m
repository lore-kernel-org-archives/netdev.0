From: David Miller <davem@davemloft.net>
Subject: [PATCH 4/6]: [CASSINI]: Set skb->truesize properly on receive
 packets.
Date: Fri, 04 Jan 2008 00:34:22 -0800 (PST)
Message-ID: <20080104.003422.172160514.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: panther@balabit.hu, bazsi@balabit.hu, hidden@sch.bme.hu
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46605
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753027AbYADIqM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jan 2008 03:46:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


[CASSINI]: Set skb->truesize properly on receive packets.

skb->truesize was not being incremented at all to
reflect the page based data added to RX SKBs.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/cassini.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/cassini.c b/drivers/net/cassini.c
index 2336223..92821ae 100644
--- a/drivers/net/cassini.c
+++ b/drivers/net/cassini.c
@@ -2037,6 +2037,7 @@ static int cas_rx_process_pkt(struct cas *cp, struct cas_rx_comp *rxc,
 
 		skb_shinfo(skb)->nr_frags++;
 		skb->data_len += hlen - swivel;
+		skb->truesize += hlen - swivel;
 		skb->len      += hlen - swivel;
 
 		get_page(page->buffer);
-- 
1.5.4.rc2.17.g257f

