From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 33/36] net: wan: ixp4xx: remove unnecessary
 platform_set_drvdata()
Date: Tue, 07 May 2013 14:02:48 +0900
Message-ID: <003201ce4ae0$1e471df0$5ad559d0$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jingoo Han <jg1.han@samsung.com>,
	'Krzysztof Halasa' <khc@pm.waw.pl>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout3.samsung.com ([203.254.224.33]:49154 "EHLO
	mailout3.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756274Ab3EGFCt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 May 2013 01:02:49 -0400
Received: from epcpsbgr2.samsung.com
 (u142.gpu120.samsung.co.kr [203.254.230.142])
 by mailout3.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MME00DU4WOE5V50@mailout3.samsung.com> for
 netdev@vger.kernel.org; Tue, 07 May 2013 14:02:48 +0900 (KST)
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure, since commit 0998d0631001288a5974afc0b2a5f568bcdecb4d
(device-core: Ensure drvdata = NULL when no driver is bound).
Thus, it is not needed to manually clear the device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/wan/ixp4xx_hss.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wan/ixp4xx_hss.c b/drivers/net/wan/ixp4xx_hss.c
index fc9d11d..e7bbdb7 100644
--- a/drivers/net/wan/ixp4xx_hss.c
+++ b/drivers/net/wan/ixp4xx_hss.c
@@ -1384,7 +1384,6 @@ static int hss_remove_one(struct platform_device *pdev)
 	unregister_hdlc_device(port->netdev);
 	free_netdev(port->netdev);
 	npe_release(port->npe);
-	platform_set_drvdata(pdev, NULL);
 	kfree(port);
 	return 0;
 }
-- 
1.7.2.5
