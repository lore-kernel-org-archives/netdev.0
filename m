From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: [PATCH][NET] gianfar: fix obviously wrong #ifdef CONFIG_GFAR_NAPI
	placement
Date: Wed, 17 Oct 2007 23:57:46 +0400
Message-ID: <20071017195746.GA15592@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf8
Cc: galak@kernel.crashing.org, afleming@freescale.com,
	apw@shadowen.org, linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: leoli@freescale.com, jgarzik@pobox.com, paulus@samba.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtsoft3.corbina.net ([85.21.88.6]:12712 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754346AbXJQT6J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Oct 2007 15:58:09 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Erroneous #ifdef introduced by 293c8513398657f6263fcdb03c87f2760cf61be4
causing NAPI-less ethernet malfunctioning.

Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
Signed-off-by: Vitaly Bordug <vbordug@ru.mvista.com>
---

if (...)
#if
	...;
#endif

good candidate for checkpatch?

 drivers/net/gianfar.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index cc288d8..38268d7 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -956,10 +956,12 @@ static int gfar_enet_open(struct net_device *dev)
 	}
 
 	err = startup_gfar(dev);
-	if (err)
+	if (err) {
 #ifdef CONFIG_GFAR_NAPI
 		napi_disable(&priv->napi);
 #endif
+		return err;
+	}
 
 	netif_start_queue(dev);
 
-- 
1.5.0.6
