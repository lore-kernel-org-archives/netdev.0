From: Himangi Saraogi <himangi774@gmail.com>
Subject: [PATCH] net: irda: delete double assignment
Date: Mon, 28 Jul 2014 20:58:12 +0530
Message-ID: <20140728152812.GA3000@himangi-Dell>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: julia.lawall@lip6.fr
To: Samuel Ortiz <samuel@sortiz.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Delete successive assignments to the same location.

A simplified version of Coccinelle semantic match that finds this problem is as
follows:

// <smpl>
@@
expression i;
@@

*i = ...;
 i = ...;
// </smpl>

Signed-off-by: Himangi Saraogi <himangi774@gmail.com>
---
Should the second assignment have been |=?
 net/irda/irlap_frame.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/irda/irlap_frame.c b/net/irda/irlap_frame.c
index 9ea0c93..4c169f6 100644
--- a/net/irda/irlap_frame.c
+++ b/net/irda/irlap_frame.c
@@ -621,7 +621,6 @@ void irlap_send_rd_frame(struct irlap_cb *self)
 
 	frame = (struct rd_frame *)skb_put(tx_skb, 2);
 
-	frame->caddr = self->caddr;
 	frame->caddr = RD_RSP | PF_BIT;
 
 	irlap_queue_xmit(self, tx_skb);
-- 
1.9.1
