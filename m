From: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>
Subject: [PATCH net,stable] net: usbnet: fix SG initialisation
Date: Fri, 10 Jan 2014 23:10:17 +0100
Message-ID: <1389391817-27204-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb@vger.kernel.org, Thomas Kear <thomas@kear.co.nz>,
	Ben Hutchings <bhutchings@solarflare.com>,
	=?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn@mork.no>,
	Ming Lei <ming.lei@canonical.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:46649 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758343AbaAJWKo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jan 2014 17:10:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 60e453a940ac ("USBNET: fix handling padding packet")
added an extra SG entry in case padding is necessary, but
failed to update the initialisation of the list. This can
cause list traversal to fall off the end of the list,
resulting in an oops.

=46ixes: 60e453a940ac ("USBNET: fix handling padding packet")
Reported-by: Thomas Kear <thomas@kear.co.nz>
Cc: Ming Lei <ming.lei@canonical.com>
Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>
---
I don't have the hardware to verify this fix.  It would be good if
someone could test it before it goes to stable...

But in case this works, it should go into v3.12 stable.


Bj=C3=B8rn

 drivers/net/usb/usbnet.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 8494bb53ebdc..aba04f561760 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -1245,7 +1245,7 @@ static int build_dma_sg(const struct sk_buff *skb=
, struct urb *urb)
 		return -ENOMEM;
=20
 	urb->num_sgs =3D num_sgs;
-	sg_init_table(urb->sg, urb->num_sgs);
+	sg_init_table(urb->sg, urb->num_sgs + 1);
=20
 	sg_set_buf(&urb->sg[s++], skb->data, skb_headlen(skb));
 	total_len +=3D skb_headlen(skb);
--=20
1.8.5.2
