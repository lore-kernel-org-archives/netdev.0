From: Peter Senna Tschudin <peter.senna@gmail.com>
Subject: [PATCH 7/20] drivers/net/irda/mcs7780.c: fix error return code
Date: Wed,  3 Oct 2012 18:18:00 +0200
Message-ID: <1349281090-10013-10-git-send-email-peter.senna@gmail.com>
Cc: kernel-janitors@vger.kernel.org, irda-users@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: samuel@sortiz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:42254 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965044Ab2JCQSb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Oct 2012 12:18:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Senna Tschudin <peter.senna@gmail.com>

Convert a nonnegative error return code to a negative one, as returned
elsewhere in the function.

A simplified version of the semantic match that finds this problem is as
follows: (http://coccinelle.lip6.fr/)

// <smpl>
(
if@p1 (\(ret < 0\|ret != 0\))
 { ... return ret; }
|
ret@p1 = 0
)
... when != ret = e1
    when != &ret
*if(...)
{
  ... when != ret = e2
      when forall
 return ret;
}
// </smpl>

Signed-off-by: Peter Senna Tschudin <peter.senna@gmail.com>

---
 drivers/net/irda/mcs7780.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/irda/mcs7780.c b/drivers/net/irda/mcs7780.c
index 1a00b59..f07c340 100644
--- a/drivers/net/irda/mcs7780.c
+++ b/drivers/net/irda/mcs7780.c
@@ -920,8 +920,10 @@ static int mcs_probe(struct usb_interface *intf,
 
 	ndev->netdev_ops = &mcs_netdev_ops;
 
-	if (!intf->cur_altsetting)
+	if (!intf->cur_altsetting) {
+		ret = -ENOMEM;
 		goto error2;
+	}
 
 	ret = mcs_find_endpoints(mcs, intf->cur_altsetting->endpoint,
 				 intf->cur_altsetting->desc.bNumEndpoints);
