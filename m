From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 04/15] net: be2net: remove unnecessary pci_set_drvdata()
Date: Mon, 21 Oct 2013 11:11:44 +0900
Message-ID: <003c01cece02$e37c8c90$aa75a5b0$%han@samsung.com>
References: <003801cece02$6abb0160$40310420$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>,
	'Sathya Perla' <sathya.perla@emulex.com>,
	'Subbu Seetharaman' <subbu.seetharaman@emulex.com>,
	'Ajit Khaparde' <ajit.khaparde@emulex.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout4.samsung.com ([203.254.224.34]:19271 "EHLO
	mailout4.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752270Ab3JUCLp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Oct 2013 22:11:45 -0400
Received: from epcpsbgr1.samsung.com
 (u141.gpu120.samsung.co.kr [203.254.230.141])
 by mailout4.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MUZ00FD2Y34A4G0@mailout4.samsung.com> for
 netdev@vger.kernel.org; Mon, 21 Oct 2013 11:11:44 +0900 (KST)
In-reply-to: <003801cece02$6abb0160$40310420$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure. Thus, it is not needed to manually clear the
device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |    2 --
 1 file changed, 2 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index f0866e2..393e3dc 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -4204,7 +4204,6 @@ static void be_remove(struct pci_dev *pdev)
 
 	pci_disable_pcie_error_reporting(pdev);
 
-	pci_set_drvdata(pdev, NULL);
 	pci_release_regions(pdev);
 	pci_disable_device(pdev);
 
@@ -4534,7 +4533,6 @@ ctrl_clean:
 	be_ctrl_cleanup(adapter);
 free_netdev:
 	free_netdev(netdev);
-	pci_set_drvdata(pdev, NULL);
 rel_reg:
 	pci_release_regions(pdev);
 disable_dev:
-- 
1.7.10.4
