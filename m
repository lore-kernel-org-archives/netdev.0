From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 11/20] drivers/net/wireless/orinoco: Use kzalloc
Date: Thu, 13 May 2010 22:02:56 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.1005132202310.6282__14087.0721116245$1273781043$gmane$org@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: Pavel Roskin <proski@gnu.org>,
	David Gibson <hermes@gibson.dropbear.id.au>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org,
	orinoco-users@lists.sourcefor
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:42016 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932771Ab0EMUDB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 May 2010 16:03:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia@diku.dk>

Use kzalloc rather than the combination of kmalloc and memset.

The semantic patch that makes this change is as follows:
(http://coccinelle.lip6.fr/)

// <smpl>
@@
expression x,size,flags;
statement S;
@@

-x = kmalloc(size,flags);
+x = kzalloc(size,flags);
 if (x == NULL) S
-memset(x, 0, size);
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
 drivers/net/wireless/orinoco/orinoco_usb.c |    4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff -u -p a/drivers/net/wireless/orinoco/orinoco_usb.c b/drivers/net/wireless/orinoco/orinoco_usb.c
--- a/drivers/net/wireless/orinoco/orinoco_usb.c
+++ b/drivers/net/wireless/orinoco/orinoco_usb.c
@@ -356,12 +356,10 @@ static struct request_context *ezusb_all
 {
 	struct request_context *ctx;
 
-	ctx = kmalloc(sizeof(*ctx), GFP_ATOMIC);
+	ctx = kzalloc(sizeof(*ctx), GFP_ATOMIC);
 	if (!ctx)
 		return NULL;
 
-	memset(ctx, 0, sizeof(*ctx));
-
 	ctx->buf = kmalloc(BULK_BUF_SIZE, GFP_ATOMIC);
 	if (!ctx->buf) {
 		kfree(ctx);
