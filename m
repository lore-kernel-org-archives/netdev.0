From: Doug Ledford <dledford@redhat.com>
Subject: [PATCH] net/cxgb3: fix revert error
Date: Thu, 22 Aug 2013 18:27:59 -0400
Message-ID: <5216906F.8000000@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010807090809040305090500"
Cc: Doug Ledford <dledford@redhat.com>,
	Santosh Rastapur <santosh@chelsio.com>,
	Jay Fenlason <fenlason@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Divy Le ray <divy@chelsio.com>,
	Alexey Kardashevskiy <aik@ozlabs.ru>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:18770 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753794Ab3HVW2G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Aug 2013 18:28:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010807090809040305090500
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

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

diff --git a/drivers/net/ethernet/chelsio/cxgb3/sge.c
b/drivers/net/ethernet/chelsio/cxgb3/sge.c
index 9c89dc8..632b318 100644
--- a/drivers/net/ethernet/chelsio/cxgb3/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb3/sge.c
@@ -1599,7 +1599,8 @@ static void write_ofld_wr(struct adapter *adap,
struct sk_buff *skb,
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


--------------010807090809040305090500
Content-Type: text/plain; charset=UTF-8;
 name="Attached Message Part"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="Attached Message Part"


--------------010807090809040305090500--
