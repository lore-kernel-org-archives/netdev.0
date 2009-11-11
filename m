From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: [PATCH 3/6] gianfar: Fix build with CONFIG_PM=y
Date: Wed, 11 Nov 2009 03:11:05 +0300
Message-ID: <20091111001105.GC8817@oksana.dev.rtsoft.ru>
References: <20091111001036.GA28576@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Andy Fleming <afleming@freescale.com>, Jon Loeliger <jdl@jdl.com>,
	Kumar Gopalpet-B05799 <B05799@freescale.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from imap.ru.mvista.com ([213.79.90.228]:1568 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752062AbZKKALA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2009 19:11:00 -0500
Content-Disposition: inline
In-Reply-To: <20091111001036.GA28576@oksana.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit fba4ed030cfae7efdb6b79a57b0c5a9d72c9 ("gianfar: Add Multiple
Queue Support") introduced the following build failure:

  CC      gianfar.o
gianfar.c: In function 'gfar_restore':
gianfar.c:1249: error: request for member 'napi' in something not a structure or union

This patch fixes the issue.

Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
---
 drivers/net/gianfar.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 79c28f5..a5b0038 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -1246,7 +1246,7 @@ static int gfar_restore(struct device *dev)
 		phy_start(priv->phydev);
 
 	netif_device_attach(ndev);
-	napi_enable(&priv->gfargrp.napi);
+	enable_napi(priv);
 
 	return 0;
 }
-- 
1.6.3.3

