From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 4/5] net: tulip: use pci_{get,set}_drvdata()
Date: Mon, 02 Sep 2013 17:11:53 +0900
Message-ID: <001201cea7b4$15851c40$408f54c0$%han@samsung.com>
References: <000f01cea7b3$6226fd30$2674f790$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Danny Kukawka' <danny.kukawka@bisect.de>,
	'Jeff Kirsher' <jeffrey.t.kirsher@intel.com>,
	'Jingoo Han' <jg1.han@samsung.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout2.samsung.com ([203.254.224.25]:45468 "EHLO
	mailout2.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752789Ab3IBIL5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Sep 2013 04:11:57 -0400
Received: from epcpsbgr3.samsung.com
 (u143.gpu120.samsung.co.kr [203.254.230.143])
 by mailout2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MSH008JIO3HHTN0@mailout2.samsung.com> for
 netdev@vger.kernel.org; Mon, 02 Sep 2013 17:11:54 +0900 (KST)
In-reply-to: <000f01cea7b3$6226fd30$2674f790$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the wrapper functions for getting and setting the driver data
using pci_dev instead of using dev_{get,set}_drvdata() with
&pdev->dev, so we can directly pass a struct pci_dev. This is
a purely cosmetic change.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/dec/tulip/de4x5.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/dec/tulip/de4x5.c b/drivers/net/ethernet/dec/tulip/de4x5.c
index 4c83003..2db6c57 100644
--- a/drivers/net/ethernet/dec/tulip/de4x5.c
+++ b/drivers/net/ethernet/dec/tulip/de4x5.c
@@ -2319,7 +2319,7 @@ static void de4x5_pci_remove(struct pci_dev *pdev)
 	struct net_device *dev;
 	u_long iobase;
 
-	dev = dev_get_drvdata(&pdev->dev);
+	dev = pci_get_drvdata(pdev);
 	iobase = dev->base_addr;
 
 	unregister_netdev (dev);
-- 
1.7.10.4
