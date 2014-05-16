From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH net-next v2 12/12] net: cdc_ncm: do not start timer on an empty skb
Date: Fri, 16 May 2014 21:48:29 +0200
Message-ID: <1400269709-18854-13-git-send-email-bjorn@mork.no>
References: <1400269709-18854-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <linux-usb@vger.kernel.org>,
	Alexey Orishko <alexey.orishko@gmail.com>,
	Oliver Neukum <oliver@neukum.org>,
	Enrico Mioso <mrkiko.rs@gmail.com>,
	David Laight <David.Laight@ACULAB.COM>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:52179 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754787AbaEPTsv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 May 2014 15:48:51 -0400
In-Reply-To: <1400269709-18854-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We can end up with a freshly allocated tx_curr_skb with no frames
in it.  In this case it does not make any sense to start the timer.
This avoids the timer periodically trying to start tx when there
is nothing in the queue.

Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
 drivers/net/usb/cdc_ncm.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 783c4ed96395..2d0caf1eea25 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -1069,8 +1069,8 @@ cdc_ncm_fill_tx_frame(struct usbnet *dev, struct =
sk_buff *skb, __le32 sign)
 	return skb_out;
=20
 exit_no_skb:
-	/* Start timer, if there is a remaining skb */
-	if (ctx->tx_curr_skb !=3D NULL)
+	/* Start timer, if there is a remaining non-empty skb */
+	if (ctx->tx_curr_skb !=3D NULL && n > 0)
 		cdc_ncm_tx_timeout_start(ctx);
 	return NULL;
 }
--=20
2.0.0.rc2
