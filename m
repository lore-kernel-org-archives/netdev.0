From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 12/15] net: smsc9420: remove unnecessary pci_set_drvdata()
Date: Tue, 22 Oct 2013 13:19:53 +0900
Message-ID: <001201cecedd$f5470690$dfd513b0$%han@samsung.com>
References: <000601cecedd$1981e300$4c85a900$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>,
	'Steve Glendinning' <steve.glendinning@shawell.net>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout2.samsung.com ([203.254.224.25]:58348 "EHLO
	mailout2.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751149Ab3JVETz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Oct 2013 00:19:55 -0400
Received: from epcpsbgr3.samsung.com
 (u143.gpu120.samsung.co.kr [203.254.230.143])
 by mailout2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MV100H5DYNKOLK0@mailout2.samsung.com> for
 netdev@vger.kernel.org; Tue, 22 Oct 2013 13:19:54 +0900 (KST)
In-reply-to: <000601cecedd$1981e300$4c85a900$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure. Thus, it is not needed to manually clear the
device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/smsc/smsc9420.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/smsc/smsc9420.c b/drivers/net/ethernet/smsc/smsc9420.c
index 5f9e79f..e55e336 100644
--- a/drivers/net/ethernet/smsc/smsc9420.c
+++ b/drivers/net/ethernet/smsc/smsc9420.c
@@ -1707,8 +1707,6 @@ static void smsc9420_remove(struct pci_dev *pdev)
 	if (!dev)
 		return;
 
-	pci_set_drvdata(pdev, NULL);
-
 	pd = netdev_priv(dev);
 	unregister_netdev(dev);
 
-- 
1.7.10.4
