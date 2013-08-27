From: Doug Ledford <dledford@redhat.com>
Subject: [PATCH] net/cxgb3: fix revert error
Date: Tue, 27 Aug 2013 02:11:16 -0400
Message-ID: <83d325136c59fa32b84c886d3e3f99cc58e431d2.1377583423.git.dledford@redhat.com>
Cc: Doug Ledford <dledford@redhat.com>, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50930 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752194Ab3H0GLX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Aug 2013 02:11:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Resent due to corruption in previous send.  From davem on previous
email send:

> This patch seems to have been corrupted by your email client.
> 
> Also I really need the Chelsio folks to review this when you repost
> it.

Dave, hopefully this send is able to be parsed properly.  I will assume
that since you couldn't see the patch, you assumed Chelsio needs to review
the content.  In truth, the content of this path is hardware agnostic and
right down your alley of expertise.  Your review should be sufficient for
inclusion or rejection.

728e2cc Revert "cxgb3: Check and handle the dma mapping errors"

reverted f83331b cxgb3: Check and handle the dma mapping errors,
however, in between those two there was also
be8b678 cxgb3: Correct comparisons and calculations using skb->tail and
skb-transport_header and
15dd16c cxgb3: Correct comparisons and calculations using skb->tail and
skb-transport_header

The author of the revert did not fix up the conflicts in such as way as
to preserve the other two commits, so they were reverted too.  As they
correct math issues under certain conditions, they should be retained.
This puts them back in place.

Signed-off-by: Doug Ledford <dledford@redhat.com>
---
 drivers/net/ethernet/chelsio/cxgb3/sge.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb3/sge.c b/drivers/net/ethernet/chelsio/cxgb3/sge.c
index 9c89dc8..632b318 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb3/sge.c
@@ -1599,7 +1599,8 @@ static void write_ofld_wr(struct adapter *adap, struct sk_buff *skb,
 	flits = skb_transport_offset(skb) / 8;
 	sgp = ndesc == 1 ? (struct sg_ent *)&d->flit[flits] : sgl;
 	sgl_flits = make_sgl(skb, sgp, skb_transport_header(skb),
-			     skb->tail - skb->transport_header,
+			     skb_tail_pointer(skb) -
+			     skb_transport_header(skb),
 			     adap->pdev);
 	if (need_skb_unmap()) {
 		setup_deferred_unmapping(skb, adap->pdev, sgp, sgl_flits);
-- 
1.8.1.4
