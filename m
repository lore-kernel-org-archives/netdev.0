From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 2/4] xfrm: Fix negative device refcount on offload failure.
Date: Mon, 9 Oct 2017 09:16:37 +0200
Message-ID: <1507533399-29399-3-git-send-email-steffen.klassert@secunet.com>
References: <1507533399-29399-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:49520 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753897AbdJIHQq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 9 Oct 2017 03:16:46 -0400
In-Reply-To: <1507533399-29399-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reset the offload device at the xfrm_state if the device was
not able to offload the state. Otherwise we drop the device
refcount twice.

Fixes: d77e38e612a0 ("xfrm: Add an IPsec hardware offloading API")
Reported-by: Shannon Nelson <shannon.nelson@oracle.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_device.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/xfrm/xfrm_device.c b/net/xfrm/xfrm_device.c
index acf0010..30e5746 100644
--- a/net/xfrm/xfrm_device.c
+++ b/net/xfrm/xfrm_device.c
@@ -91,6 +91,7 @@ int xfrm_dev_state_add(struct net *net, struct xfrm_state *x,
 	}
 
 	if (!dev->xfrmdev_ops || !dev->xfrmdev_ops->xdo_dev_state_add) {
+		xso->dev = NULL;
 		dev_put(dev);
 		return 0;
 	}
-- 
2.7.4
