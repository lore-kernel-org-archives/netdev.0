From: Peter Senna Tschudin <peter.senna@gmail.com>
Subject: [PATCH 8/20] drivers/net/irda/pxaficp_ir.c: fix error return code
Date: Wed,  3 Oct 2012 18:17:59 +0200
Message-ID: <1349281090-10013-9-git-send-email-peter.senna@gmail.com>
Cc: kernel-janitors@vger.kernel.org, irda-users@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: samuel@sortiz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:43600 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964823Ab2JCQSa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Oct 2012 12:18:30 -0400
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
 drivers/net/irda/pxaficp_ir.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/irda/pxaficp_ir.c b/drivers/net/irda/pxaficp_ir.c
index 002a442..858de05 100644
--- a/drivers/net/irda/pxaficp_ir.c
+++ b/drivers/net/irda/pxaficp_ir.c
@@ -846,8 +846,10 @@ static int pxa_irda_probe(struct platform_device *pdev)
 		goto err_mem_2;
 
 	dev = alloc_irdadev(sizeof(struct pxa_irda));
-	if (!dev)
+	if (!dev) {
+		err = -ENOMEM;
 		goto err_mem_3;
+	}
 
 	SET_NETDEV_DEV(dev, &pdev->dev);
 	si = netdev_priv(dev);
