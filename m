From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 02/36] net: can: c_can: remove unnecessary
 platform_set_drvdata()
Date: Tue, 07 May 2013 13:14:13 +0900
Message-ID: <000d01ce4ad9$54f93560$feeba020$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jingoo Han <jg1.han@samsung.com>,
	'AnilKumar Ch' <anilkumar@ti.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout1.samsung.com ([203.254.224.24]:32819 "EHLO
	mailout1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752346Ab3EGEOP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 May 2013 00:14:15 -0400
Received: from epcpsbgr4.samsung.com
 (u144.gpu120.samsung.co.kr [203.254.230.144])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MME00JZLUFOG9K0@mailout1.samsung.com> for
 netdev@vger.kernel.org; Tue, 07 May 2013 13:14:13 +0900 (KST)
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure, since commit 0998d0631001288a5974afc0b2a5f568bcdecb4d
(device-core: Ensure drvdata = NULL when no driver is bound).
Thus, it is not needed to manually clear the device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/can/c_can/c_can_platform.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/can/c_can/c_can_platform.c b/drivers/net/can/c_can/c_can_platform.c
index d63b919..6b6130b 100644
--- a/drivers/net/can/c_can/c_can_platform.c
+++ b/drivers/net/can/c_can/c_can_platform.c
@@ -234,7 +234,6 @@ static int c_can_plat_probe(struct platform_device *pdev)
 	return 0;
 
 exit_free_device:
-	platform_set_drvdata(pdev, NULL);
 	free_c_can_dev(dev);
 exit_iounmap:
 	iounmap(addr);
@@ -255,7 +254,6 @@ static int c_can_plat_remove(struct platform_device *pdev)
 	struct resource *mem;
 
 	unregister_c_can_dev(dev);
-	platform_set_drvdata(pdev, NULL);
 
 	free_c_can_dev(dev);
 	iounmap(priv->base);
-- 
1.7.2.5
