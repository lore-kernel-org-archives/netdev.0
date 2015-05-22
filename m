From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH net,stable-4.0] cdc_ncm: Fix tx_bytes statistics
Date: Fri, 22 May 2015 13:15:22 +0200
Message-ID: <1432293322-11928-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Florian Bruhin <me@the-compiler.org>, linux-usb@vger.kernel.org,
	Oliver Neukum <oliver@neukum.org>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>,
	Ben Hutchings <ben.hutchings@codethink.co.uk>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:39585 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751161AbbEVLP6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 May 2015 07:15:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The tx_curr_frame_payload field is u32. When we try to calculate a
small negative delta based on it, we end up with a positive integer
close to 2^32 instead.  So the tx_bytes pointer increases by about
2^32 for every transmitted frame.

=46ix by calculating the delta as a signed long.

Cc: Ben Hutchings <ben.hutchings@codethink.co.uk>
Reported-by: Florian Bruhin <me@the-compiler.org>
=46ixes: 7a1e890e2168 ("usbnet: Fix tx_bytes statistic running backward=
 in cdc_ncm")
Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/usb/cdc_ncm.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index c3e4da9e79ca..8067b8fbb0ee 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -1182,7 +1182,7 @@ cdc_ncm_fill_tx_frame(struct usbnet *dev, struct =
sk_buff *skb, __le32 sign)
 	 * payload data instead.
 	 */
 	usbnet_set_skb_tx_stats(skb_out, n,
-				ctx->tx_curr_frame_payload - skb_out->len);
+				(long)ctx->tx_curr_frame_payload - skb_out->len);
=20
 	return skb_out;
=20
--=20
2.1.4
