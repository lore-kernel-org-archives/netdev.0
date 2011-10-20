From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] bnx2x: fix skb truesize underestimation
Date: Thu, 20 Oct 2011 11:00:23 +0200
Message-ID: <1319101223.3781.7.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Eilon Greenstein <eilong@broadcom.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:40922 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752033Ab1JTJA1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2011 05:00:27 -0400
Received: by ggnb1 with SMTP id b1so2559808ggn.19
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2011 02:00:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bnx2x allocates a full page per fragment.

We must account in skb->truesize, the size of the fragment, not the used
part of it.
    
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index dd8ee56..580b44e 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -454,7 +454,7 @@ static int bnx2x_fill_frag_skb(struct bnx2x *bp, struct bnx2x_fastpath *fp,
 		skb_fill_page_desc(skb, j, old_rx_pg.page, 0, frag_len);
 
 		skb->data_len += frag_len;
-		skb->truesize += frag_len;
+		skb->truesize += SGE_PAGE_SIZE * PAGES_PER_SGE;
 		skb->len += frag_len;
 
 		frag_size -= frag_len;
