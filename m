From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH V2 2/4] net: irda: remove unnecessary platform_set_drvdata()
Date: Tue, 28 May 2013 14:03:49 +0900
Message-ID: <000201ce5b60$bd82d860$38888920$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jingoo Han <jg1.han@samsung.com>,
	Kuninori Morimoto <kuninori.morimoto.gx@renesas.com>,
	Samuel Ortiz <samuel@sortiz.org>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout3.samsung.com ([203.254.224.33]:13155 "EHLO
	mailout3.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932124Ab3E1FD6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 May 2013 01:03:58 -0400
Received: from epcpsbgr2.samsung.com
 (u142.gpu120.samsung.co.kr [203.254.230.142])
 by mailout3.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MNH00FASSQ9S2L0@mailout3.samsung.com> for
 netdev@vger.kernel.org; Tue, 28 May 2013 14:03:49 +0900 (KST)
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure, since commit 0998d0631001288a5974afc0b2a5f568bcdecb4d
(device-core: Ensure drvdata = NULL when no driver is bound).
Thus, it is not needed to manually clear the device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
Acked-by: Kuninori Morimoto <kuninori.morimoto.gx@renesas.com>
---
 drivers/net/irda/bfin_sir.c |    1 -
 drivers/net/irda/sh_irda.c  |    1 -
 drivers/net/irda/sh_sir.c   |    1 -
 3 files changed, 3 deletions(-)

diff --git a/drivers/net/irda/bfin_sir.c b/drivers/net/irda/bfin_sir.c
index 22b4527..c74f384 100644
--- a/drivers/net/irda/bfin_sir.c
+++ b/drivers/net/irda/bfin_sir.c
@@ -794,7 +794,6 @@ static int bfin_sir_remove(struct platform_device *pdev)
 	kfree(self->rx_buff.head);
 	free_netdev(dev);
 	kfree(sir_port);
-	platform_set_drvdata(pdev, NULL);
 
 	return 0;
 }
diff --git a/drivers/net/irda/sh_irda.c b/drivers/net/irda/sh_irda.c
index 9448587..4455425 100644
--- a/drivers/net/irda/sh_irda.c
+++ b/drivers/net/irda/sh_irda.c
@@ -838,7 +838,6 @@ static int sh_irda_remove(struct platform_device *pdev)
 	sh_irda_remove_iobuf(self);
 	iounmap(self->membase);
 	free_netdev(ndev);
-	platform_set_drvdata(pdev, NULL);
 
 	return 0;
 }
diff --git a/drivers/net/irda/sh_sir.c b/drivers/net/irda/sh_sir.c
index 24aefcd..89682b4 100644
--- a/drivers/net/irda/sh_sir.c
+++ b/drivers/net/irda/sh_sir.c
@@ -796,7 +796,6 @@ static int sh_sir_remove(struct platform_device *pdev)
 	sh_sir_remove_iobuf(self);
 	iounmap(self->membase);
 	free_netdev(ndev);
-	platform_set_drvdata(pdev, NULL);
 
 	return 0;
 }
-- 
1.7.10.4
