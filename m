From: Yijing Wang <wangyijing@huawei.com>
Subject: [PATCH 3/7] net, ipw2x00: remove redundant D0 power state set
Date: Thu, 30 May 2013 18:21:29 +0800
Message-ID: <1369909289-35752-1-git-send-email-wangyijing@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <linux-wireless@vger.kernel.org>,
	<netdev@vger.kernel.org>, Hanjun Guo <guohanjun@huawei.com>,
	Jiang Liu <liuj97@gmail.com>,
	Yijing Wang <wangyijing@huawei.com>
To: Stanislav Yakovlev <stas.yakovlev@gmail.com>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:11209 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030344Ab3E3KVq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 May 2013 06:21:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pci_enable_device() will set device power state to D0,
so it's no need to do it again in ipw2100_pci_init_one().

Signed-off-by: Yijing Wang <wangyijing@huawei.com>
---
 drivers/net/wireless/ipw2x00/ipw2100.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/ipw2x00/ipw2100.c b/drivers/net/wireless/ipw2x00/ipw2100.c
index 15920aa..f8ab193 100644
--- a/drivers/net/wireless/ipw2x00/ipw2100.c
+++ b/drivers/net/wireless/ipw2x00/ipw2100.c
@@ -6242,8 +6242,6 @@ static int ipw2100_pci_init_one(struct pci_dev *pci_dev,
 	if ((val & 0x0000ff00) != 0)
 		pci_write_config_dword(pci_dev, 0x40, val & 0xffff00ff);
 
-	pci_set_power_state(pci_dev, PCI_D0);
-
 	if (!ipw2100_hw_is_adapter_in_system(dev)) {
 		printk(KERN_WARNING DRV_NAME
 		       "Device not found via register read.\n");
-- 
1.7.1
