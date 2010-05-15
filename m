From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 36/37] drivers/net/wireless/orinoco: Use kmemdup
Date: Sat, 15 May 2010 23:24:07 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.1005152323480.21345__5092.67734964869$1273958736$gmane$org@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: Pavel Roskin <proski@gnu.org>,
	David Gibson <hermes@gibson.dropbear.id.au>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org,
	orinoco-users@lists.sourcefor
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:35502 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755841Ab0EOVYM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 May 2010 17:24:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia@diku.dk>

Use kmemdup when some other buffer is immediately copied into the
allocated region.

A simplified version of the semantic patch that makes this change is as
follows: (http://coccinelle.lip6.fr/)

// <smpl>
@@
expression from,to,size,flag;
statement S;
@@

-  to = \(kmalloc\|kzalloc\)(size,flag);
+  to = kmemdup(from,size,flag);
   if (to==NULL || ...) S
-  memcpy(to, from, size);
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
 drivers/net/wireless/orinoco/wext.c |    4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff -u -p a/drivers/net/wireless/orinoco/wext.c b/drivers/net/wireless/orinoco/wext.c
--- a/drivers/net/wireless/orinoco/wext.c
+++ b/drivers/net/wireless/orinoco/wext.c
@@ -993,11 +993,9 @@ static int orinoco_ioctl_set_genie(struc
 		return -EINVAL;
 
 	if (wrqu->data.length) {
-		buf = kmalloc(wrqu->data.length, GFP_KERNEL);
+		buf = kmemdup(extra, wrqu->data.length, GFP_KERNEL);
 		if (buf == NULL)
 			return -ENOMEM;
-
-		memcpy(buf, extra, wrqu->data.length);
 	} else
 		buf = NULL;
 
