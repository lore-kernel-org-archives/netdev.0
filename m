From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] niu: remove one compound_head() call
Date: Fri, 16 Jan 2015 05:39:30 -0800
Message-ID: <1421415570.11734.130.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f174.google.com ([209.85.213.174]:56551 "EHLO
	mail-ig0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751314AbbAPNjc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2015 08:39:32 -0500
Received: by mail-ig0-f174.google.com with SMTP id hn15so3372546igb.1
        for <netdev@vger.kernel.org>; Fri, 16 Jan 2015 05:39:32 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

After a "page = alloc_page(mask);", we do not need to use
compound_head() : page already points to the right place.

This would be true even if using alloc_pages().

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 drivers/net/ethernet/sun/niu.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/sun/niu.c b/drivers/net/ethernet/sun/niu.c
index 0c6416213837..4b51f903fb73 100644
--- a/drivers/net/ethernet/sun/niu.c
+++ b/drivers/net/ethernet/sun/niu.c
@@ -3341,8 +3341,7 @@ static int niu_rbr_add_page(struct niu *np, struct rx_ring_info *rp,
 
 	niu_hash_page(rp, page, addr);
 	if (rp->rbr_blocks_per_page > 1)
-		atomic_add(rp->rbr_blocks_per_page - 1,
-			   &compound_head(page)->_count);
+		atomic_add(rp->rbr_blocks_per_page - 1, &page->_count);
 
 	for (i = 0; i < rp->rbr_blocks_per_page; i++) {
 		__le32 *rbr = &rp->rbr[start_index + i];
