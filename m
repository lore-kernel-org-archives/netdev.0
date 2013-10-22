From: Jingoo Han <jg1.han@samsung.com>
Subject: [PATCH 09/15] net: r8169: remove unnecessary pci_set_drvdata()
Date: Tue, 22 Oct 2013 13:18:25 +0900
Message-ID: <000f01cecedd$c0c62b30$42528190$%han@samsung.com>
References: <000601cecedd$1981e300$4c85a900$%han@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, 'Jingoo Han' <jg1.han@samsung.com>,
	'Realtek linux nic maintainers' <nic_swsd@realtek.com>,
	'Francois Romieu' <romieu@fr.zoreil.com>
To: "'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout2.samsung.com ([203.254.224.25]:58063 "EHLO
	mailout2.samsung.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750861Ab3JVES1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Oct 2013 00:18:27 -0400
Received: from epcpsbgr2.samsung.com
 (u142.gpu120.samsung.co.kr [203.254.230.142])
 by mailout2.samsung.com (Oracle Communications Messaging Server 7u4-24.01
 (7.0.4.24.0) 64bit (built Nov 17 2011))
 with ESMTP id <0MV100AQUYK5NTL0@mailout2.samsung.com> for
 netdev@vger.kernel.org; Tue, 22 Oct 2013 13:18:26 +0900 (KST)
In-reply-to: <000601cecedd$1981e300$4c85a900$%han@samsung.com>
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
index 3397cee..7993875 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -6811,7 +6811,6 @@ static void rtl_remove_one(struct pci_dev *pdev)
 
 	rtl_disable_msi(pdev, tp);
 	rtl8169_release_board(pdev, dev, tp->mmio_addr);
-	pci_set_drvdata(pdev, NULL);
 }
 
 static const struct net_device_ops rtl_netdev_ops = {
-- 
1.7.10.4
