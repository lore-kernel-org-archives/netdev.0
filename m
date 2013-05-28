From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH V2 4/4] net: wan: remove unnecessary platform_set_drvdata()
Date: Tue, 28 May 2013 14:08:17 +0900
Message-ID: <000401ce5b61$5d26eaf0$1774c0d0$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jingoo Han <jg1.han@samsung.com>,
	'Krzysztof Halasa' <khc@pm.waw.pl>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout2.samsung.com ([203.254.224.25]:54507 "EHLO
	mailout2.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932124Ab3E1FIT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 May 2013 01:08:19 -0400
Received: from epcpsbgr4.samsung.com
 (u144.gpu120.samsung.co.kr [203.254.230.144])
 by mailout2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MNH00LM2SX9USM0@mailout2.samsung.com> for
 netdev@vger.kernel.org; Tue, 28 May 2013 14:08:18 +0900 (KST)
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
 1 file changed, 1 deletion(-)

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
1.7.10.4
