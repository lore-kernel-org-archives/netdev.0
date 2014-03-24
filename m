From: Joe Perches <joe@perches.com>
Subject: [PATCH net-next] chelsio: Remove addressof casts to same type
Date: Mon, 24 Mar 2014 10:45:12 -0700
Message-ID: <1395683112.13968.59.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Dimitris Michailidis <dm@chelsio.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Using addressof then casting to the original type is pointless,
so remove these unnecessary casts.

Done via coccinelle script:

$ cat typecast.cocci 
@@
type T;
T foo;
@@

-	(T *)&foo
+	&foo

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index cc04d09..a7a41e0 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -3220,8 +3220,8 @@ static int cxgb4_clip_get(const struct net_device *dev,
 	c.op_to_write = htonl(FW_CMD_OP(FW_CLIP_CMD) |
 			FW_CMD_REQUEST | FW_CMD_WRITE);
 	c.alloc_to_len16 = htonl(F_FW_CLIP_CMD_ALLOC | FW_LEN16(c));
-	*(__be64 *)&c.ip_hi = *(__be64 *)(lip->s6_addr);
-	*(__be64 *)&c.ip_lo = *(__be64 *)(lip->s6_addr + 8);
+	c.ip_hi = *(__be64 *)(lip->s6_addr);
+	c.ip_lo = *(__be64 *)(lip->s6_addr + 8);
 	return t4_wr_mbox_meat(adap, adap->mbox, &c, sizeof(c), &c, false);
 }
 
@@ -3236,8 +3236,8 @@ static int cxgb4_clip_release(const struct net_device *dev,
 	c.op_to_write = htonl(FW_CMD_OP(FW_CLIP_CMD) |
 			FW_CMD_REQUEST | FW_CMD_READ);
 	c.alloc_to_len16 = htonl(F_FW_CLIP_CMD_FREE | FW_LEN16(c));
-	*(__be64 *)&c.ip_hi = *(__be64 *)(lip->s6_addr);
-	*(__be64 *)&c.ip_lo = *(__be64 *)(lip->s6_addr + 8);
+	c.ip_hi = *(__be64 *)(lip->s6_addr);
+	c.ip_lo = *(__be64 *)(lip->s6_addr + 8);
 	return t4_wr_mbox_meat(adap, adap->mbox, &c, sizeof(c), &c, false);
 }
 
