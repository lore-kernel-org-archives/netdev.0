From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 07/15] net: e100: remove unnecessary pci_set_drvdata()
Date: Mon, 21 Oct 2013 11:13:07 +0900
Message-ID: <003f01cece03$14f9ebf0$3eedc3d0$%han@samsung.com>
References: <003801cece02$6abb0160$40310420$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>,
	'Jeff Kirsher' <jeffrey.t.kirsher@intel.com>,
	'Aaron Brown' <aaron.f.brown@intel.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout2.samsung.com ([203.254.224.25]:52229 "EHLO
	mailout2.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752138Ab3JUCNd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Oct 2013 22:13:33 -0400
Received: from epcpsbgr4.samsung.com
 (u144.gpu120.samsung.co.kr [203.254.230.144])
 by mailout2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MUZ00L7PY3T83E0@mailout2.samsung.com> for
 netdev@vger.kernel.org; Mon, 21 Oct 2013 11:13:07 +0900 (KST)
In-reply-to: <003801cece02$6abb0160$40310420$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure. Thus, it is not needed to manually clear the
device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/intel/e100.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/e100.c b/drivers/net/ethernet/intel/e100.c
index ada6e21..cbaba44 100644
--- a/drivers/net/ethernet/intel/e100.c
+++ b/drivers/net/ethernet/intel/e100.c
@@ -2985,7 +2985,6 @@ err_out_free_res:
 err_out_disable_pdev:
 	pci_disable_device(pdev);
 err_out_free_dev:
-	pci_set_drvdata(pdev, NULL);
 	free_netdev(netdev);
 	return err;
 }
@@ -3003,7 +3002,6 @@ static void e100_remove(struct pci_dev *pdev)
 		free_netdev(netdev);
 		pci_release_regions(pdev);
 		pci_disable_device(pdev);
-		pci_set_drvdata(pdev, NULL);
 	}
 }
 
-- 
1.7.10.4
