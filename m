From: "Arthur D. Kepner" <akepner@sgi.com>
Subject: Re: [PATCH bk-2.6.10] tg3:align IP headers from 5701 in PCI-X mode
Date: Tue, 11 Jan 2005 12:49:05 -0600 (CST)
Message-ID: <Pine.LNX.4.21.0501111242590.14715-100000@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>, jgarzik@pobox.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


(Resend. Local clock was off and my archived reply appears to have 
been generated prior to the message to which I was responding.... )

On Mon, 10 Jan 2005, David S. Miller wrote:

> Let's just do this all the time for this case, adding new config
> options for stuff like this does nothing more than create confusion.

OK, you mean like the following?

diffstats:
 tg3.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletion(-) 

Signed-off-by: Arthur Kepner <akepner@sgi.com>

===== drivers/net/tg3.c 1.222 vs edited =====
--- 1.222/drivers/net/tg3.c	2004-11-15 15:53:08 -08:00
+++ edited/drivers/net/tg3.c	2005-01-10 13:35:33 -08:00
@@ -2702,7 +2702,11 @@ static int tg3_rx(struct tg3 *tp, int bu
 
 		len = ((desc->idx_len & RXD_LEN_MASK) >> RXD_LEN_SHIFT) - 4; /* omit crc */
 
-		if (len > RX_COPY_THRESHOLD) {
+		if (len > RX_COPY_THRESHOLD 
+			&& tp->rx_offset == 2
+			/* rx_offset != 2 iff this is a 5701 card running
+			 * in PCI-X mode [see tg3_get_invariants()] */
+		) {
 			int skb_size;
 
 			skb_size = tg3_alloc_rx_skb(tp, opaque_key,
-- 
Arthur
