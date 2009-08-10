From: Sathya Perla <sathyap@serverengines.com>
Subject: [net-next-2.6 PATCH 2/3] be2net: fix bad queue traversal in
	be_rx_q_clean()
Date: Mon, 10 Aug 2009 19:13:23 +0530
Message-ID: <20090810134323.GA10857@serverengines.com>
Reply-To: Sathya Perla <sathyap@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:43298 "EHLO
	sperla-laptop.localdomain" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754567AbZHJNnv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Aug 2009 09:43:51 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using "for(tail != head)" to traverse a queue from tail to head
fails in the case of a fully filled queue. Use "for(used != 0)" instead.

Signed-off-by: Sathya Perla <sathyap@serverengines.com>
---
 drivers/net/benet/be_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index f7f8660..49c17ed 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -1010,7 +1010,7 @@ static void be_rx_q_clean(struct be_adapter *adapter)
 
 	/* Then free posted rx buffer that were not used */
 	tail = (rxq->head + rxq->len - atomic_read(&rxq->used)) % rxq->len;
-	for (; tail != rxq->head; index_inc(&tail, rxq->len)) {
+	for (; atomic_read(&rxq->used) > 0; index_inc(&tail, rxq->len)) {
 		page_info = get_rx_page_info(adapter, tail);
 		put_page(page_info->page);
 		memset(page_info, 0, sizeof(*page_info));
-- 
1.6.0.4

