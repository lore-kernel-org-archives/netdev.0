From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 15/15] net: enic: remove unnecessary pci_set_drvdata()
Date: Fri, 18 Oct 2013 09:25:29 +0900
Message-ID: <00be01cecb98$8cabcd20$a6036760$%han@samsung.com>
References: <00ae01cecb97$44d45770$ce7d0650$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>,
	'Christian Benvenuti' <benve@cisco.com>,
	'Sujith Sankar' <ssujith@cisco.com>,
	'Govindarajulu Varadarajan' <govindarajulu90@gmail.com>,
	'Neel Patel' <neepatel@cisco.com>,
	'Nishank Trivedi' <nistrive@cisco.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout2.samsung.com ([203.254.224.25]:41961 "EHLO
	mailout2.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755976Ab3JRAZb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Oct 2013 20:25:31 -0400
Received: from epcpsbgr2.samsung.com
 (u142.gpu120.samsung.co.kr [203.254.230.142])
 by mailout2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MUU00J4M96I0PE0@mailout2.samsung.com> for
 netdev@vger.kernel.org; Fri, 18 Oct 2013 09:25:30 +0900 (KST)
In-reply-to: <00ae01cecb97$44d45770$ce7d0650$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure. Thus, it is not needed to manually clear the
device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/cisco/enic/enic_main.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
index 7b756cf9..ff78dfa 100644
--- a/drivers/net/ethernet/cisco/enic/enic_main.c
+++ b/drivers/net/ethernet/cisco/enic/enic_main.c
@@ -2309,7 +2309,6 @@ err_out_release_regions:
 err_out_disable_device:
 	pci_disable_device(pdev);
 err_out_free_netdev:
-	pci_set_drvdata(pdev, NULL);
 	free_netdev(netdev);
 
 	return err;
@@ -2338,7 +2337,6 @@ static void enic_remove(struct pci_dev *pdev)
 		enic_iounmap(enic);
 		pci_release_regions(pdev);
 		pci_disable_device(pdev);
-		pci_set_drvdata(pdev, NULL);
 		free_netdev(netdev);
 	}
 }
-- 
1.7.10.4
