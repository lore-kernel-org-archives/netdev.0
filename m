From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 1/5] wan: dscc4: remove unnecessary pci_set_drvdata()
Date: Mon, 09 Dec 2013 12:29:46 +0900
Message-ID: <000a01cef48e$e88de5f0$b9a9b1d0$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>,
	'Francois Romieu' <romieu@fr.zoreil.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout1.samsung.com ([203.254.224.24]:58787 "EHLO
	mailout1.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760287Ab3LID3r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Dec 2013 22:29:47 -0500
Received: from epcpsbgr4.samsung.com
 (u144.gpu120.samsung.co.kr [203.254.230.144])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MXI00JV4SDMO880@mailout1.samsung.com> for
 netdev@vger.kernel.org; Mon, 09 Dec 2013 12:29:46 +0900 (KST)
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure. Thus, it is not needed to manually clear the
device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/wan/dscc4.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/wan/dscc4.c b/drivers/net/wan/dscc4.c
index 851dc7b..288610d 100644
--- a/drivers/net/wan/dscc4.c
+++ b/drivers/net/wan/dscc4.c
@@ -699,8 +699,6 @@ static void dscc4_free1(struct pci_dev *pdev)
 	for (i = 0; i < dev_per_card; i++)
 		unregister_hdlc_device(dscc4_to_dev(root + i));
 
-	pci_set_drvdata(pdev, NULL);
-
 	for (i = 0; i < dev_per_card; i++)
 		free_netdev(root[i].dev);
 	kfree(root);
-- 
1.7.10.4
