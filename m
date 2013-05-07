From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 13/36] net: ethernet: ethoc: remove unnecessary
 platform_set_drvdata()
Date: Tue, 07 May 2013 13:30:57 +0900
Message-ID: <001d01ce4adb$ab9eb000$02dc1000$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jingoo Han <jg1.han@samsung.com>,
	'Jiri Pirko' <jiri@resnulli.us>,
	'Danny Kukawka' <danny.kukawka@bisect.de>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout3.samsung.com ([203.254.224.33]:43134 "EHLO
	mailout3.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932228Ab3EGEbA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 May 2013 00:31:00 -0400
Received: from epcpsbgr1.samsung.com
 (u141.gpu120.samsung.co.kr [203.254.230.141])
 by mailout3.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MME00D86V7I5V40@mailout3.samsung.com> for
 netdev@vger.kernel.org; Tue, 07 May 2013 13:30:58 +0900 (KST)
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure, since commit 0998d0631001288a5974afc0b2a5f568bcdecb4d
(device-core: Ensure drvdata = NULL when no driver is bound).
Thus, it is not needed to manually clear the device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/ethoc.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/ethoc.c b/drivers/net/ethernet/ethoc.c
index 5722bc6..cf579fb 100644
--- a/drivers/net/ethernet/ethoc.c
+++ b/drivers/net/ethernet/ethoc.c
@@ -1147,8 +1147,6 @@ static int ethoc_remove(struct platform_device *pdev)
 	struct net_device *netdev = platform_get_drvdata(pdev);
 	struct ethoc *priv = netdev_priv(netdev);
 
-	platform_set_drvdata(pdev, NULL);
-
 	if (netdev) {
 		netif_napi_del(&priv->napi);
 		phy_disconnect(priv->phy);
-- 
1.7.2.5
