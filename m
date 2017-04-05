From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] net: ethernet: wiznet: avoid format string exposure
Date: Wed, 5 Apr 2017 14:39:35 -0700
Message-ID: <20170405213935.GA4561@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Akinobu Mita <akinobu.mita@gmail.com>,
        Eric Dumazet <edumazet@google.com>, Tejun Heo <tj@kernel.org>,
        Florian Westphal <fw@strlen.de>,
        Bhaktipriya Shridhar <bhaktipriya96@gmail.com>,
        Masahiro Yamada <yamada.masahiro@socionext.com>,
        netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f54.google.com ([74.125.83.54]:35442 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934026AbdDEVjh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Apr 2017 17:39:37 -0400
Received: by mail-pg0-f54.google.com with SMTP id 81so16276381pgh.2
        for <netdev@vger.kernel.org>; Wed, 05 Apr 2017 14:39:37 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While unlikely, this makes sure any format strings in the device name
can't exposure information via the resulting workqueue name.

Signed-off-by: Kees Cook <keescook@chromium.org>
---
 drivers/net/ethernet/wiznet/w5100.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/wiznet/w5100.c b/drivers/net/ethernet/wiznet/w5100.c
index f90267f0519f..2bdfb39215e9 100644
--- a/drivers/net/ethernet/wiznet/w5100.c
+++ b/drivers/net/ethernet/wiznet/w5100.c
@@ -1152,7 +1152,8 @@ int w5100_probe(struct device *dev, const struct w5100_ops *ops,
 	if (err < 0)
 		goto err_register;
 
-	priv->xfer_wq = alloc_workqueue(netdev_name(ndev), WQ_MEM_RECLAIM, 0);
+	priv->xfer_wq = alloc_workqueue("%s", WQ_MEM_RECLAIM, 0,
+					netdev_name(ndev));
 	if (!priv->xfer_wq) {
 		err = -ENOMEM;
 		goto err_wq;
-- 
2.7.4


-- 
Kees Cook
Pixel Security
