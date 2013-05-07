From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 36/36] net: irda: sh_sir: remove unnecessary
 platform_set_drvdata()
Date: Tue, 07 May 2013 14:07:56 +0900
Message-ID: <003501ce4ae0$d60b7d50$822277f0$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jingoo Han <jg1.han@samsung.com>,
	Samuel Ortiz <samuel@sortiz.org>,
	Wei Yongjun <yongjun_wei@trendmicro.com.cn>,
	Kuninori Morimoto <kuninori.morimoto.gx@renesas.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout4.samsung.com ([203.254.224.34]:57383 "EHLO
	mailout4.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758419Ab3EGFH6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 May 2013 01:07:58 -0400
Received: from epcpsbgr1.samsung.com
 (u141.gpu120.samsung.co.kr [203.254.230.141])
 by mailout4.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MME0022LWX1D8D0@mailout4.samsung.com> for
 netdev@vger.kernel.org; Tue, 07 May 2013 14:07:56 +0900 (KST)
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure, since commit 0998d0631001288a5974afc0b2a5f568bcdecb4d
(device-core: Ensure drvdata = NULL when no driver is bound).
Thus, it is not needed to manually clear the device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/irda/sh_sir.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

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
1.7.2.5
