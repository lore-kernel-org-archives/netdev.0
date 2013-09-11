From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 39/52] net: r8169: remove unnecessary pci_set_drvdata()
Date: Wed, 11 Sep 2013 17:01:42 +0900
Message-ID: <007101ceaec5$26c5a340$7450e9c0$%han@samsung.com>
References: <004a01ceaebf$43f920f0$cbeb62d0$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>,
	'Realtek linux nic maintainers' <nic_swsd@realtek.com>,
	'Francois Romieu' <romieu@fr.zoreil.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout3.samsung.com ([203.254.224.33]:58600 "EHLO
	mailout3.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750936Ab3IKIBo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 04:01:44 -0400
Received: from epcpsbgr4.samsung.com
 (u144.gpu120.samsung.co.kr [203.254.230.144])
 by mailout3.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MSY005BXBM389U0@mailout3.samsung.com> for
 netdev@vger.kernel.org; Wed, 11 Sep 2013 17:01:42 +0900 (KST)
In-reply-to: <004a01ceaebf$43f920f0$cbeb62d0$%han@samsung.com>
Content-language: ko
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The driver core clears the driver data to NULL after device_release
or on probe failure. Thus, it is not needed to manually clear the
device driver data to NULL.

Signed-off-by: Jingoo Han <jg1.han@samsung.com>
---
 drivers/net/ethernet/realtek/r8169.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 6f87f2c..c5f8e70 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -6810,7 +6810,6 @@ static void rtl_remove_one(struct pci_dev *pdev)
 
 	rtl_disable_msi(pdev, tp);
 	rtl8169_release_board(pdev, dev, tp->mmio_addr);
-	pci_set_drvdata(pdev, NULL);
 }
 
 static const struct net_device_ops rtl_netdev_ops = {
-- 
1.7.10.4
